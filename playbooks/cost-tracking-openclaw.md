# Quest 1 — Cost-Tracking für OpenClaw Bot

Status: In Arbeit (started 2026-02-24)

## Ziel
Transparente Kosten-/Nutzungs-Telemetrie mit minimaler operativer Last.

## Implementierungsstand
- Basisskript erstellt: `scripts/cost-tracker-openclaw.sh`
- Output-Ziel: `logs/cost-tracker/*.json`
- Nächster Schritt: Schema stabilisieren + tägliche Aggregation (CSV/Markdown Report)

## Nächste Tasks
1. Output-Felder auf echte Kostenmetriken normalisieren (`tokens`, `cached`, `model`, `session`)
2. Daily summary generator (`scripts/cost-report-daily.sh`)
3. Optionaler Cron-Job (nur nach Freigabe)
