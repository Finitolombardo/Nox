# HEARTBEAT PROTOKOLL (NOX)

## Ziel
Früherkennung von Verzettelung + Kostenkontrolle.

## Ablauf pro Heartbeat
1. Infrastruktur-Quickcheck
   - `df -h /`
   - `openclaw status --deep`
2. Cost Snapshot erfassen
   - `./scripts/cost-snapshot.sh`
3. Verzettelungs-Alarm prüfen (60m Fenster) [DERZEIT DEAKTIVIERT]
   - `./scripts/verzettelung-alarm.sh 60`
   - Kill-Switch: `.alerts/verzettelung.disabled`
4. Backup-Alarm prüfen (Silent Success, Noisy Failure)
   - `./scripts/backup-alert-check.sh`
5. Cash-Score Report (22:00 UTC, Telegram)
   - `./scripts/cash-score-report.sh`
6. Quest-Update (Heartbeat-getrieben)
   - Offene Quests in Notion prüfen
   - Nächste konkrete Aktion je Quest aktualisieren (keine vagen TODOs)

## Alarmregel (ROI-Logik)
Wir nutzen `total_tokens_sum` als API-Kosten-Proxy:
- Wenn `total_tokens_sum` im 60-Minuten-Fenster steigt (`delta > 0`)
- UND in Notion kein strategischer Fortschritt erkannt wird (`Status = Erledigt` in den letzten 60 Minuten),
=> `ALERT: Verzettelung erkannt` ausgeben.

## Antwortverhalten
- Bei Alert: Konkrete Eskalation mit Handlungsoptionen senden.
- Ohne Alert: `HEARTBEAT_OK`.
