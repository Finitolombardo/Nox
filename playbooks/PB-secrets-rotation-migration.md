# PB-secrets-rotation-migration

Status: Active (v1)
Last updated: 2026-02-24 UTC
Owner: NOX

## Ziel
Secrets aus unsicheren Klartext-Pfaden (z. B. `Environment=` in Unit-Files) in kontrollierte Secret-Dateien migrieren, Berechtigungen härten und Schlüssel rotieren.

## Evidence Sources (für diese Version)
- Unit inspection: `systemctl --user cat openclaw-gateway.service`, `systemctl cat n8n.service`
- Runtime overview: `openclaw status --deep`
- Architekturkontext: `playbooks/architecture-current.md`
- Secret-Inventar: `playbooks/secrets-inventory-redacted.md`

## Scope
- OpenClaw Gateway (user systemd)
- n8n (systemd)
- Weitere Dienste mit Klartext-Secrets in Unit/Config

---

## 1) Risiko-Befund
- Klartext-Secrets in `Environment=` sind mit Leserechten auf Unit-Konfig einsehbar.
- Das erhöht Leak-Risiko bei Host-Zugriff, Backups, Logs und Fehlkonfigurationen.

---

## 2) Zielarchitektur
- Keine Secret-Werte mehr direkt in Unit-Dateien.
- Secrets liegen in dedizierten Dateien mit `0600`.
- Units nutzen `EnvironmentFile=` statt Inline-`Environment=`.
- Rotationszyklen sind pro Secret dokumentiert.

---

## 3) Migrationsplan (pro Service)

## 3.1 Inventarisieren
- Secret-Namen, Owner-Service, Speicherort erfassen (ohne Werte).
- Kritikalität taggen: HIGH / MEDIUM / LOW.

## 3.2 Secret-Datei anlegen
- Beispielpfade:
  - OpenClaw: `/root/.config/openclaw/secrets.env`
  - n8n: `/etc/n8n/secrets.env`
- Berechtigungen:
  - `chown <service-user>:<service-group> <file>`
  - `chmod 600 <file>`

## 3.3 Unit umstellen
- Inline-Secret-`Environment=` entfernen.
- `EnvironmentFile=<pfad>` ergänzen.
- Non-secret Variablen können in Unit bleiben.

## 3.4 Safe Reload
- `systemctl daemon-reload` (bzw. `systemctl --user daemon-reload`)
- betroffenen Dienst gezielt neu starten
- Health/Smoke-Test ausführen

## 3.5 Rotate exposed keys
- Bereits offengelegte Schlüssel als kompromittiert behandeln.
- Neue Keys erzeugen, binden, alte sofort entwerten.

---

## 4) Pflicht-Checks nach Umstellung
- `openclaw status --deep` grün
- `systemctl --user status openclaw-gateway` grün
- `systemctl status n8n` grün
- Kritische Flows funktionsfähig (Bot, n8n Trigger, API Calls)
- Unit-Dateien enthalten keine Secret-Werte mehr

---

## 5) Rollback
Falls Migration fehlschlägt:
1. Letzte funktionierende Unit + Secret-Datei-Version wiederherstellen.
2. Dienst neu laden/restarten.
3. Smoke-Tests wiederholen.
4. Ursache dokumentieren, dann zweite Migration mit kleinerem Scope.

---

## 6) Rotation Policy (Baseline)
- HIGH (Bot/API/Auth Tokens): alle 30 Tage
- MEDIUM (Service-Keys intern): alle 60 Tage
- LOW (nicht internet-exponierte interne Credentials): alle 90 Tage
- Sofortrotation bei Leak-Verdacht oder Team-/Rollenwechsel

---

## 7) Dokumentationspflicht
Nach jeder Änderung aktualisieren:
- `playbooks/secrets-inventory-redacted.md`
- `playbooks/architecture-current.md` (wenn Pfade/Units geändert)
- Incident/Change-Log mit Zeitpunkt + Ergebnis

---

## 8) Guardrails
- Keine Secret-Werte in Chat, Commit-History oder Tickets.
- Kein Bulk-Change über mehrere kritische Services gleichzeitig.
- Pro Schritt verifizieren, erst dann nächste Änderung.
