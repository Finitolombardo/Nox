# n8n Campaign Evolution Playbook

## Ziel
Aus Outreach-Daten automatisch bessere Pitches erzeugen und nur cash-relevante Varianten skalieren.

## Scope
- OG Scraper / Lead Intake
- Instantly Kampagnenversand
- Reply Classifier
- Angle Evaluator v2 (Cash-Score)
- Pitch Generator / Mutation
- Notion Datenrückfluss

## Datenbanken (Notion)
- Campaign Index
- Pitch Variants
- Mutation History
- Mutation Variables
- Angle Policy
- Angle Experiment State
- Replies
- Quests

## Kernformel
Cash-Score v2:
`S = (0.6 * P) + (0.25 * R) + (0.15 * O)`

- `P` = Positive Reply Rate (%)
- `R` = Reply Rate (%)
- `O` = Open Rate (%)

## End-to-End Flow
1. Lead Intake (CSV/Sheets/Apollo/etc.)
2. OG Scraper normalisiert + validiert
3. Instantly receives leads + sends sequences
4. Replies werden klassifiziert (positive/negative/neutral)
5. KPIs zurück in Pitch Variants / Mutation History
6. Angle Evaluator berechnet Cash-Score je Variante
7. Winner bleibt/skalieren, Loser stoppen
8. Pitch Generator mutiert nur im erlaubten Regelraum
9. Campaign Index auf neue aktive Variante aktualisieren

## Guardrails (Pflicht)
- Keine Kampagnenentscheidung ohne Positive-Reply-Signal
- Keine Mutation ohne Relation zu Campaign + Pitch + Niche
- Kein Scale ohne KPI-Vergleich vs. Vorwoche
- Bei schlechter Performance: Kill-Regel statt Schönreden

## Kill-Regeln
- Positive Reply = 0 nach 100 Sends -> Hook/Offer wechseln
- Reply Rate unter Zielwert für 2 Zyklen -> Pitch pausieren
- Bounce > Schwelle -> Lead-Quelle/Validation fixen

## Nischen-Isolation
- Pro Nische eigene Angle Policy (Beauty / Steuerberater / Makler)
- Kein Cross-Lernen ohne explizites `niche_key`
- Kampagnen strikt per Niche segmentieren

## Daily Ops (15 min)
1. KPI-Check (Sends, Replies, Positives, Calls)
2. Cash-Score Top/Flop je Kampagne
3. 1 Entscheidung dokumentieren
4. Quests aktualisieren (In Arbeit / Erledigt)

## Weekly Ops (60 min)
1. Gewinner-Varianten konsolidieren
2. Verlierer archivieren
3. Neue Mutation-Hypothesen definieren
4. Lead-Quellenqualität bewerten

## Fehlersuche
- Wenn KPIs fehlen: zuerst Relation-Integrity prüfen
- Wenn Instantly voll: OutreachDone-Purge Workflow prüfen
- Wenn Drift: Quests + Todoist Sync kontrollieren

## Erfolgsdefinition
- Mehr positive Replies pro 100 Sends
- Mehr gebuchte Calls pro Woche
- Weniger Tokens pro strategischem Fortschritt
- Stabiler MRR-Aufbau statt KPI-Theater
