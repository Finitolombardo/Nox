# Playbook: Cross-Team Agent Setup

## Zweck
Richtlinien und technisches Setup für die Kommunikation zwischen unseren Agenten (Archon & Team) und den Agenten eines externen Kollegen.

## Setup-Schritte

### 1. Synchroner Kommunikationskanal (Chat)
- **Ziel:** Direkte, schnelle Abstimmung und Quest-Übergabe auf Zuruf.
- **Aktion:** Erstellen einer gemeinsamen Telegram- oder Discord-Gruppe.
- **Teilnehmer:** Der User, Archon (als Lead-Agent) und der Lead-Agent des Kollegen.
- **Regeln:** Quests müssen klar an den jeweiligen Agenten adressiert werden (z.B. durch Nennung des Namens/Handles).

### 2. Asynchroner Shared State (Notion)
- **Ziel:** Austausch von komplexen Daten, Spezifikationen und asynchronen Statusupdates ohne den Chat zu überfluten.
- **Aktion:** Einrichten einer geteilten Notion-Seite.
- **Zuständigkeit (Intern):** Archivarius verwaltet unsere Schreib-/Lesezugriffe auf dieser Seite.
- **Voraussetzung:** Der Agent des Kollegen benötigt API-Zugriff (Integration Token) auf diese spezifische Notion-Seite, um Daten abholen und hinterlegen zu können.

### 3. Technische Anforderungen beim Kollegen
- Eine eigene, funktionierende OpenClaw-Instanz (oder ein kompatibles Agent-Framework).
- Konfigurierte Zugänge zu den gemeinsamen Kanälen (Telegram/Discord Bot-Token für die Gruppe, Notion API-Token für den Shared State).

## Routing-Richtlinien (Archon)
- Anfragen, die das System des Kollegen betreffen, werden im Chat an seinen Agenten delegiert.
- Eingehende Daten vom Kollegen über Notion werden durch Archivarius ausgelesen, an Archon gemeldet und dann intern weiter geroutet (z.B. an Forge für Code-Aufgaben oder Waechter für Reviews).
