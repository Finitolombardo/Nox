# PB-integration-leads-analytics.md

## Status
- Status: WORKING
- Last checked: 2026-02-26
- Quick-Test: `sudo -n /usr/local/bin/gog-headless sheets metadata <sheet_id> --account admin@alphamindhub.com --json`
- Result: SUCCESS

## Scope
This playbook provides instructions for querying and managing lead/financial data directly from Google Sheets using the OpenClaw `gog-headless` wrapper. 

## Known-Good Configuration
- **Wrapper**: `sudo -n /usr/local/bin/gog-headless`
- **Account**: `admin@alphamindhub.com`
- **Core Sheet**: `1rxYAuzn8_tM53qaCnwd3YukMvwm_4AeIQ-hLLAqZfyE` ("Kopie von Kampagnen-Leads")

## Core Operations

### 1. Retrieve Lead Data
To count leads, read the header, or fetch specific rows for analytics:
```bash
sudo -n /usr/local/bin/gog-headless sheets get <sheet_id> "Alle Leads!A1:Z10" --account admin@alphamindhub.com --json
```

### 2. Append New Leads
To insert a new lead into the sheet (e.g., via chat command):
```bash
sudo -n /usr/local/bin/gog-headless sheets append <sheet_id> "Alle Leads!A:C" --values-json '[["Query", "Name", "Email"]]' --insert INSERT_ROWS --account admin@alphamindhub.com --json
```

### 3. Update Existing Lead Status
To update a status column (e.g. changing cell D2 to "Contacted"):
```bash
sudo -n /usr/local/bin/gog-headless sheets update <sheet_id> "Alle Leads!D2:D2" --values-json '[["Contacted"]]' --input USER_ENTERED --account admin@alphamindhub.com --json
```

## Daily Operations
- When the user asks for metrics (like "How many leads do we have?"), use `sheets get` to fetch the data.
- Process the output JSON to answer conversational queries without requiring the user to open Google Sheets.
- Always use `--json` or `--plain` to prevent interactive prompts.
- Do not print any raw tokens or secrets.