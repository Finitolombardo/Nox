# Whatsapp-Bot — Systemdatei

## Zweck
Automatisierter WhatsApp-Dialog für Erstkontakt, Qualifizierung und Follow-up.

## Ziel-Outcome
- Schnellere Reaktionszeit auf Inbound/Outbound Replies
- Höhere Terminquote aus Chat-Konversationen
- Saubere Übergabe qualifizierter Leads in CRM/Instantly

## Inputs
- Kontakt (Name, Telefonnummer, optional Segment/Nische)
- Kampagnen-/Pitch-Kontext (optional)
- Trigger: Inbound Nachricht oder Outbound Sequenz-Event

## Outputs
- Antwortklassifikation (Interesse, Rückfrage, kein Bedarf, später)
- Nächster Schritt (Terminlink senden, Reminder, Hand-off)
- Status-Update in CRM/Notion

## Empfohlene n8n-Bausteine
- Webhook / Provider Trigger (WhatsApp API)
- Intent-/Reply-Klassifikation
- Regelwerk für nächste Antwort
- CRM/Notion Update
- Optional: Übergabe an Buchungsbot

## KPI
- Time-to-first-reply
- Antwortquote
- Qualifizierungsquote
- Übergabequote an Booking

## Risiken / Fehlerfälle
- Nummernformat ungültig
- Rate-Limits des Messaging-Providers
- Fehlklassifikation bei kurzen Antworten

## Status in diesem Repo
- Kein dedizierter Workflow-JSON mit Name "Whatsapp-Bot" im aktuellen n8n-workflows Export gefunden.
- Für produktiven Einsatz neuen dedizierten Workflow mit stabiler ID anlegen.
