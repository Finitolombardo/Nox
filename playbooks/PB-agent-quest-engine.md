# PB-agent-quest-engine

Status: Active (v1)
Last updated: 2026-02-24 UTC
Owner: NOX

## Ziel
Agenten sollen sich bei Leerlauf kontrolliert "weiterbilden" und eigenständig sinnvolle Quests ziehen – ohne Kostenexplosion oder Sicherheitsrisiko.

## Kernprinzip
Leerlauf != frei herumprobieren.
Leerlauf = vordefinierte **Quest-Queue** mit ROI-Ranking.

## Quest-Typen
1) **Skill Quest** (Lernen)
- Neues Tool/Playbook verstehen
- Ergebnis: 1 kurzes Lernmemo + 1 anwendbarer SOP-Verbesserungsvorschlag

2) **System Quest** (Verbessern)
- Drift prüfen, Doku härten, KPI-Lücken schließen
- Ergebnis: konkreter Patch-Entwurf (ohne riskante Ausführung)

3) **Revenue Quest** (Cash)
- Offer-Text verbessern, Follow-up-Skripte testen, Bottleneck-Analyse
- Ergebnis: 1 umsetzbare Maßnahme mit erwarteter Umsatzwirkung

## Idle Trigger
Wenn ein Agent 60 Minuten keinen primären Task hat:
- Nimm höchste offene Quest mit Score
- max Laufzeit: 15 Minuten
- max Output: 200 Wörter
- danach zurück in Wartezustand

## Quest Scoring
Score = (Business Impact * 3) + (Risk Reduction * 2) + (Time-to-Value) - (Cost Estimate)
Nur Quests mit Score >= 6 ausführen.

## Guardrails
- Keine externen Sends ohne GO
- Keine Änderungen an Produktivsystemen ohne GO
- Keine Secret-Ausgabe
- Max 2 Idle-Quests pro Agent/Tag

## Pflicht-Output pro Quest
- Quest-ID
- Warum jetzt?
- Ergebnis
- Nächste empfohlene Aktion
- Bedarf an User-GO (ja/nein)

## Quest-Backlog Datei
Pfad: `memory/agent-quests.json`
Format pro Item:
- id
- ownerAgent
- type
- objective
- score
- status (open|doing|done|blocked)
- lastRunAt
