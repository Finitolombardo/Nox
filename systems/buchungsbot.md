# Buchungsbot — Systemdatei

## Zweck
Automatisierte Terminbuchung inkl. Slot-Auswahl, Bestätigung und Reminder.

## Ziel-Outcome
- Weniger No-Shows
- Mehr gebuchte Erstgespräche
- Kürzere Zeit von Interesse → Termin

## Inputs
- Lead-Kontakt + Kanal (WhatsApp/Email)
- Kalenderverfügbarkeit (z. B. Cal.com)
- Gesprächstyp / Dauer

## Outputs
- Terminbuchung
- Bestätigungsnachricht mit Kalenderlink
- Reminder-Kette (z. B. T-24h / T-2h)

## Empfohlene Integrationen
- Cal.com / Google Calendar
- WhatsApp/Email für Benachrichtigungen
- Notion/CRM für Status-Update

## KPI
- Booking Rate
- Show-up Rate
- No-show Rate
- Time-to-booking

## Risiken / Fehlerfälle
- Calendar Sync Konflikte
- Ungültige Zeitzonen
- Doppelte Buchungen

## Status in diesem Repo
- In Website-/Systemlogik als Kernmodul vorhanden ("WhatsApp Booking Bot" / "Buchungsbot").
- Im aktuellen n8n-workflows Export kein eindeutig benannter dedizierter Buchungsbot-Workflow enthalten.
