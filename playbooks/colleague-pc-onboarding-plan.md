# Plan: Einrichtung auf dem PC deines Kollegen (OpenClaw Remote Setup)

## Ziel
Sichere, reproduzierbare Einrichtung ohne Trial-and-Error – mit klaren Abnahmechecks.

## Phase 1 — Verbindungsaufbau & Zugriff
1. Node/Remote-Verbindung koppeln (damit ich den PC direkt sehen/steuern kann).
2. Rechte prüfen (Admin/Sudo, Netzwerkzugriff, Firewall-Regeln).
3. Baseline erfassen: OS, Laufzeit, offene Ports, bestehende Dienste.

## Phase 2 — Ist-Zustand inventarisieren
1. OpenClaw-Status prüfen (`openclaw status --deep`).
2. Service-Manager prüfen (systemd/PM2/Docker).
3. Konfig-/Datenpfade dokumentieren.
4. Integrationen prüfen (Telegram/Discord/Notion/Sheets/Todoist).

## Phase 3 — Härtung & Struktur
1. Secrets aus Inline-Configs in sichere EnvFiles (`0600`) überführen.
2. Monitoring/Healthchecks verifizieren.
3. Backup- und Recovery-Pfad validieren.
4. Playbooks vor Ort anlegen/aktualisieren (Deploy, Incident, Recovery).

## Phase 4 — Agent Operating System ausrollen
1. Rollen definieren (Main, Ops, Revenue, Content).
2. Autonomiegrenzen setzen (L1/L2/L3 mit GO-Gates).
3. Daily Reporting-Format fixieren.

## Phase 5 — Abnahme (Definition of Done)
- OpenClaw & Kernservices grün.
- Integrationen funktionieren.
- Keine Klartext-Secrets in produktiven Unit-Dateien.
- Playbooks aktuell.
- Weekly Check + manuelle Kontrollpunkte eingerichtet.

## Deliverables
- Architektur-Snapshot
- Secrets-Inventar (redacted)
- Incident/Deploy/Recovery Playbooks
- Offene Risks + Prioritätenliste
