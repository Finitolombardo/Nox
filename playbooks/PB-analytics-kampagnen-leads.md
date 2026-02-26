# PB-analytics-kampagnen-leads.md

## Status
- Status: WORKING
- Last checked: 2026-02-26
- Sheet ID: `1rxYAuzn8_tM53qaCnwd3YukMvwm_4AeIQ-hLLAqZfyE`
- Sheet Name: "Kopie von Kampagnen-Leads"

## Scope
This playbook defines how OpenClaw interacts with the main Lead Database (Google Sheets) for business analytics and lead management.

## Schema / Data Structure
The main tab is `'Alle Leads'`. 
Key Columns:
- `query`, `name`, `name_for_emails`
- `category`, `type`
- `phone`, `website`, `address`, `city`, `state`, `country`
- `rating`, `reviews`
- `business_status`

## Standard Operations (Headless)
All operations MUST use the headless wrapper with `--account admin@alphamindhub.com` and `--json` or `--plain`.

**1. Get total row count / metadata:**
`sudo -n /usr/local/bin/gog-headless sheets metadata 1rxYAuzn8_tM53qaCnwd3YukMvwm_4AeIQ-hLLAqZfyE --account admin@alphamindhub.com --json`

**2. Read specific range (e.g., first 5 leads):**
`sudo -n /usr/local/bin/gog-headless sheets get 1rxYAuzn8_tM53qaCnwd3YukMvwm_4AeIQ-hLLAqZfyE "'Alle Leads'!A2:Z6" --account admin@alphamindhub.com --json`

**3. Append a new lead:**
`sudo -n /usr/local/bin/gog-headless sheets append 1rxYAuzn8_tM53qaCnwd3YukMvwm_4AeIQ-hLLAqZfyE "'Alle Leads'!A:Z" --values-json '[["Search Query", "Company GmbH", "Contact Name", "", "Marketing", "", "+4912345678", "https://example.com"]]' --insert INSERT_ROWS --account admin@alphamindhub.com`

## Analytics Workflow
When the user asks for analytics:
1. Fetch metadata to understand the scope.
2. Fetch relevant ranges (e.g., categories or specific columns).
3. Process the JSON data internally and return the insight (e.g., count of leads per category).
