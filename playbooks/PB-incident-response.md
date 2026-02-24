# PB-Incident-Response

Status: Active (v1)
Last updated: 2026-02-24 UTC
Owner: NOX

## Ziel
Ausfälle und Degradationen schnell eindämmen, Ursache isolieren, Service stabil wiederherstellen.

## Scope
- OpenClaw Gateway
- n8n
- Docker Services (Firecrawl, Monitoring-Stack)
- Edge/Ingress-relevante Vorfälle (nginx, öffentliche Endpunkte)

---

## 1) Incident-Level

## P1 (kritisch)
- Kernservice down (OpenClaw/n8n nicht erreichbar)
- Öffentliche Kernfunktion tot
- Breiter User-Impact oder Datenverlust-Risiko

## P2 (hoch)
- Teilfunktion ausgefallen
- Hohe Fehlerrate, aber Service noch teilweise nutzbar

## P3 (mittel)
- Performance/Instabilität ohne harten Ausfall
- Warnungen mit absehbarem Risiko

Regel: Bei Unsicherheit immer höher einstufen (P1 > P2 > P3).

---

## 2) Erste 5 Minuten (Containment)
1. Incident deklarieren (Zeit + betroffene Services + Symptom)
2. Schreibstop für riskante Changes (kein neues Deploy)
3. Schnellzustand erfassen:
   - `openclaw status --deep`
   - `systemctl --user status openclaw-gateway`
   - `systemctl status n8n docker`
   - `docker ps`
   - `ss -ltnup`
4. Impact eingrenzen: wer/was ist konkret betroffen?
5. Entscheidung: Hotfix vs sofort Rollback (aus PB-deploy-rollback)

---

## 3) Diagnose-Flow (Hypothese-getrieben)

## 3.1 Gateway/OpenClaw
- Ist Gateway reachable?
- Channel-Health (Telegram) grün?
- Neue Security/Config-Warnungen?

## 3.2 n8n
- Prozess up?
- UI + Webhook-Basis erreichbar?
- Klemmen Worker oder Queue-ähnliche Läufe?

## 3.3 Docker
- Restart-Loops?
- Health-Checks failing?
- Unerwartete Port-Exposures oder Port-Konflikte?

## 3.4 Edge
- 80/443 antworten?
- TLS/Proxy-Fehlverhalten?
- Upstream erreichbar?

Regel: Immer nur **eine** aktive Hypothese gleichzeitig testen.

---

## 4) Entscheidungsbaum

## Fall A: klarer Change hat Incident ausgelöst
=> Sofort Rollback auf letzten stabilen Stand.

## Fall B: kein klarer Trigger, aber Service kritisch degradiert
=> Minimalinvasive Stabilisierung (Neustart betroffener Unit/Container), dann Re-Test.

## Fall C: Verdacht auf Credential/Config-Fehler
=> Secret-Quelle prüfen (redacted), keine Werte im Chat posten, ggf. Secret rotieren.

## Fall D: Datenrisiko/Integrität unklar
=> Schreiboperationen stoppen, Backups/Recovery-Pfad priorisieren.

---

## 5) Recovery-Schritte
1. Gewählte Maßnahme durchführen (Rollback/Restart/Fix)
2. Pflicht-Smoke-Tests:
   - `openclaw status --deep` grün
   - n8n erreichbar + 1 kritischer Testlauf
   - betroffene Docker-Services healthy
3. 10–15 Minuten Stabilitätsbeobachtung
4. Incident-Level herunterstufen oder schließen

---

## 6) Kommunikationsprotokoll (kurz, hart, verwertbar)
- **Was ist kaputt?**
- **Was ist der Impact?**
- **Was ist die nächste Aktion in den nächsten 10 Minuten?**
- **Wann nächstes Update?**

Keine Spekulation ohne Evidenz.

---

## 7) Postmortem (max 15 Minuten nach Stabilisierung)
Dokumentiere:
- Startzeit / Endzeit
- Schweregrad (P1/P2/P3)
- Root Cause (bestätigt oder wahrscheinlich)
- Welche Signale hätten früher warnen können?
- Konkrete Präventionsmaßnahmen (Owner + Deadline)

Update-Pflicht:
- `playbooks/architecture-current.md` (bei Topologie-/Serviceänderungen)
- `playbooks/secrets-inventory-redacted.md` (bei Secret-Änderungen)

---

## 8) Guardrails
- Kein Blind-Retry-Spam
- Kein paralleles Multi-Fixing
- Kein ungeprüfter „Quickfix“ in Produktion
- Keine Secret-Leaks in Logs/Chat

---

## 9) KPIs
- MTTD (Detection): so niedrig wie möglich
- MTTR (Recovery): < 10 Minuten für bekannte Fehlerbilder
- Wiederkehrende Incidents pro Ursache: fallend
- Dokumentationsquote Postmortem: 100%
