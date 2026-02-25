# PB-capabilities-and-integrations.md
# Zweck: Source of Truth für Skills/Integrationen, damit der Agent NICHT “vergisst”, was er kann.
# Regel: Kurz halten. Keine Secrets. Nur Status + Quick-Tests + Fix-Pfade.

## TL;DR (für den Agenten)
- Bei jeder neuen Session: NICHT behaupten “kein Zugriff”.
- Erst Capability Map checken, dann 1 Quick-Test pro Tool.
- Wenn Auth failt: INCIDENT loggen + Fix-Schritt nennen.

---

## 1) Integrationen (Soll-Zustand)
### Notion (API)
- Status: SHOULD WORK (per API verbunden)
- Quick-Test:
  - Liste 1 Seite/DB-Entry (limit=1) aus der Quest/Tasks DB
- Wenn fail:
  - 401/403 → Token/Integration kaputt oder Rechte fehlen
  - Fix-Pfad: Skills/Notion Auth prüfen, Notion Integration für die DB freigeben

### Todoist (API)
- Status: SHOULD WORK (per API verbunden)
- Quick-Test:
  - Liste 5 aktive Tasks (limit=5)
- Wenn fail:
  - 401 → API Token falsch/abgelaufen
  - Fix: Token in Skills/Env aktualisieren

### Gmail / Google Workspace (API)
- Status: SHOULD WORK (wenn Auth gesetzt)
- Quick-Test:
  - Suche 1 Mail in INBOX (limit=1)
- Wenn fail:
  - OAuth expired → neu login
  - Fix: Google OAuth refresh / Re-auth

### Google Sheets / Drive (API)
- Status: SHOULD WORK (wenn Auth gesetzt)
- Quick-Test:
  - Liste 1 Spreadsheet / 1 Drive folder item (limit=1)
- Wenn fail:
  - Project/Quota/Scopes → GOOGLE_CLOUD_PROJECT setzen oder OAuth erneuern

---

## 2) Session-Start Routine (MUST)
Wenn User sagt: “check notion”, “hack quests ab”, “sync”, dann:

1) Capability Check (LOW COST)
   - Notion Quick-Test (limit=1)
   - Todoist Quick-Test (limit=5)
   - Gmail Quick-Test (limit=1)
   - Sheets/Drive Quick-Test (limit=1)
   => Wenn 1 Tool failt: STOP und sag exakt welches Tool + Fehler + Fix-Step.

2) Task Execution
   - Notion: offene Quests laden, Status/Responsible updaten
   - Todoist: Tasks abhaken/erstellen
   - Ergebnis kurz reporten

---

## 3) Logging Regeln
- Wenn etwas NEU verbunden wird: schreibe FACT/DECISION in MEMORY (kurz).
- Wenn etwas kaputt ist: schreibe INCIDENT (Symptom, Root cause, Fix, Prevention).
- Nie Secrets speichern.

---

## 4) Anti-Bloat
- Keine großen Config-Dumps in Prompt.
- Max 1–2 Playbooks pro Request laden.
## 5) UPDATE POLICY (MUST)
When a Quick-Test succeeds:
- Update the corresponding integration playbook with:
  - "Status: WORKING"
  - Timestamp
  - What was tested (exact API/tool call)
  - Any required env/config keys (names only, no secrets)
  - Known-good parameters (e.g., DB IDs, property names) if relevant

When a Quick-Test fails:
- Update the corresponding integration playbook with:
  - "Status: BROKEN"
  - Timestamp
  - Exact error message
  - Likely cause
  - Fix steps
- Also write an INCIDENT entry to memory (short, no secrets)

Never paste secrets into playbooks.
Keep updates minimal (<= 10 lines per event).
