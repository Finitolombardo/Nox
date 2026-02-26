# Blog Autopilot (Alpha_Mind_Hub) — Approval Gate

## Trigger
- Telegram command: `blog: <thema>`
- oder Notion-Eintrag in Blog Queue

## Pipeline
1. Idee erfassen (`topic`, `audience`, `goal`, `target_offer`)
2. Draft erzeugen (Titel, Outline, Artikel, Meta, CTA)
3. In Notion als `Draft erstellt` speichern
4. Telegram-Notify: "Draft bereit — antworte JA zum Publish"
5. Bei `JA`: Commit + Push ins Repo `Alpha_Mind_Hub`
6. Bei `NEIN`: Status `Überarbeiten`

## Guardrails
- Kein Publish ohne explizites `JA`
- Jeder Artikel enthält mind. 1 CTA zur Sales-Seite (VOIDRA/obsidian_nexus)
- Conversion-first Struktur (Problem -> Friction -> Lösung -> CTA)

## KPI
- CTR vom Blog zur Sales-Seite
- Anzahl gebuchter Calls aus Blog-Traffic
- Artikel pro Woche (Ziel: 3)
