[MODE: tool] [PLAYBOOK: PB-integration-google-workspace-gog.md] [MEMORY: write] [COST: low]

Task: Persist the successful Drive copy result as a durable record.

Rules:
- Do not expose secrets (no env content, no tokens).
- Store only non-sensitive metadata: source_file_id, new_file_id, name, link, timestamp (UTC), command used (sanitized), exit_code.
- Avoid duplicates: if a record for the same new_file_id exists, do not write again.

Where to write:
1) Update the playbook file PB-integration-google-workspace-gog.md with a "Known-Good Evidence" section.
2) Append a single JSON line event to /home/agentadmin/.openclaw/memory/_telemetry/events-$(date -u +%F).jsonl with type "gog.drive.copy.success".
3) Add a stable memory note under /home/agentadmin/.openclaw/memory/stable/facts/GOOGLE_DRIVE_COPIES.md listing latest copy at top.

Use this concrete evidence:
- source_file_id: 1mmbgpNWjIYdxycgMILbypeVwuNX5w6QrWeSIGlXc5BU
- new_file_id: 1rxYAuzn8_tM53qaCnwd3YukMvwm_4AeIQ-hLLAqZfyE
- name: "Kopie von Kampagnen-Leads"
- link: https://docs.google.com/spreadsheets/d/1rxYAuzn8_tM53qaCnwd3YukMvwm_4AeIQ-hLLAqZfyE/edit?usp=drivesdk
- exit_code: 0
- sanitized_cmd: sudo -n /usr/local/bin/gog-headless drive copy <source_file_id> "<new_name>" --plain --no-input --account admin@alphamindhub.com
