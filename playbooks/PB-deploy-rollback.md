# PB-Deploy-Rollback

Status: Active (v1)
Last updated: 2026-02-24 UTC
Owner: NOX

## Ziel
Deploys ohne Roulette: schnell ausrollen, sofort verifizieren, bei Fehlern in <10 Minuten sauber zurück.

## Evidence Sources (für diese Version)
- Runtime checks: `openclaw status --deep`, `docker ps`, `ss -ltnup`
- Service control: `systemctl status n8n docker`, `systemctl --user status openclaw-gateway`
- Architekturbasis: `playbooks/architecture-current.md`
- Secret-Policy-Basis: `playbooks/secrets-inventory-redacted.md`

## Scope
- OpenClaw Gateway (user systemd)
- n8n (systemd)
- Docker-basierte Services (u. a. Firecrawl/Monitoring)
- Nginx-Edge bleibt stabil und wird nur mit eigener Freigabe geändert

---

## 1) Pre-Deploy Gate (Pflicht)

## 1.1 Änderung definieren
- Was wird geändert? (Service, Version, Config)
- Risiko-Level: niedrig / mittel / hoch
- Erfolgskriterium in 1 Satz (z. B. "n8n erreichbar + Webhook ok + keine Error-Spikes")

## 1.2 Backup-Snapshot
- Workspace/Config-Backup erstellen
- Bei DB-relevanten Änderungen: DB-Snapshot vor Deploy
- Backup-Pfad dokumentieren

## 1.3 Readiness-Checks
- `openclaw status --deep`
- `docker ps`
- `systemctl status n8n docker`
- `systemctl --user status openclaw-gateway`
- `ss -ltnup` (Port-Baseline)

Wenn ein Check rot ist: **Deploy stoppen**.

---

## 2) Deploy-Prozedur (Standard)

## 2.1 Reihenfolge
1. Niedrigrisiko-Komponenten zuerst
2. Kernservices (n8n/OpenClaw)
3. Exposed Services zuletzt

## 2.2 Rollout-Regeln
- Immer nur **eine** Änderungseinheit gleichzeitig
- Nach jeder Einheit sofort Smoke-Test
- Kein zweiter Change, bevor der erste grün ist

## 2.3 Pflicht-Smoke-Tests
- OpenClaw: `openclaw status --deep` = Gateway/Telegram OK
- n8n: UI erreichbar + 1 Test-Workflow
- Docker: Container healthy/up, keine Restart-Loops
- Edge: öffentliche Endpunkte antworten erwartungsgemäß

---

## 3) Go/No-Go Entscheidung

**GO**, wenn:
- Alle Pflicht-Smoke-Tests grün
- Keine neuen kritischen Warnungen
- Keine signifikanten Error/Latency-Spikes

**NO-GO**, wenn:
- Kernfunktion bricht
- Health degradet > 5 Minuten
- Fehlerbild unklar / nicht reproduzierbar

Bei NO-GO: sofort Rollback (Abschnitt 4).

---

## 4) Rollback-Prozedur (<10 Min Ziel)

## 4.1 Trigger
- Service down / 5xx-Spike / Auth-Fehler / Webhook-Ausfall

## 4.2 Maßnahmen
1. Letzte Änderung identifizieren (Service + Timestamp)
2. Vorherigen Stand wiederherstellen:
   - vorherige Konfig/Unit
   - vorheriges Container-Image/Tag
   - vorherigen App-Stand
3. Service gezielt neu laden/restarten
4. Smoke-Tests wiederholen
5. Incident kurz dokumentieren (Ursache-Hypothese + nächste Prävention)

## 4.3 Verifikation nach Rollback
- `openclaw status --deep` grün
- betroffene Services healthy
- keine akuten User-Impact-Symptome

---

## 5) Service-spezifische Notes

## OpenClaw Gateway
- Laufzeit über user-systemd
- Unit/Pfade in `playbooks/architecture-current.md`
- Keine Secret-Werte in Logs oder Chat posten

## n8n
- Laufzeit über `n8n.service`
- Vor Änderungen: aktive kritische Workflows identifizieren
- Nach Deploy: mindestens 1 End-to-End Trigger testen

## Docker Services
- Vor Deploy aktuelle Container/Tags sichern
- Bei Fehler: auf vorheriges Image/Config zurück

---

## 6) Post-Deploy Dokumentation (Pflicht)
- Was wurde geändert?
- Start/End-Zeit
- Ergebnis (grün/gelb/rot)
- Falls Rollback: Grund + Dauer + Präventionsmaßnahme
- Update in:
  - `playbooks/architecture-current.md` (wenn Topologie geändert)
  - `playbooks/secrets-inventory-redacted.md` (wenn Secret-Quellen geändert)

---

## 7) KPI-Zielwerte für Deploy-Qualität
- Erfolgsquote Deploys: > 90%
- Mean Time to Recovery (MTTR): < 10 Minuten
- Ungeplante Downtime pro Deploy: < 5 Minuten
- Rollback-Dokumentation: 100%

---

## 8) Anti-Drift Regeln
- Kein Ad-hoc Deploy ohne Pre-Deploy Gate
- Keine parallelen riskanten Änderungen
- Kein „quick fix“ ohne nachgelagerte Doku
- Secrets niemals im Klartext in Unit-Dateien langfristig belassen
