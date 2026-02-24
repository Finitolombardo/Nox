# Ops Rule: Cron lines go in crontab, not in the shell
- Always insert cron lines via `crontab -e`, not directly in the shell.
- Example installation steps:
  1. Run `crontab -e` to edit.
  2. Add the cron lines and save.
- Avoid using filenames with double extensions like `heartbeat.sh.sh`, which can lead to remote command errors.

# Notizen über Avisto
- Nationalität: Polnisch
- Alter: 32 Jahre
- Ziel: Einen OpenClaw-Agenten bauen.NOX Projekt: Persönliches Lebens- und Entscheidungs-System mit AR, Biometrie, Skillbäumen und Quest-Engine
Ziel: Menschen im echten Leben messbar besser machen durch Entscheidungsverstärkung, nicht Motivation
Technologie: AR-Brille mit Eye-Tracking + Edge-Box + Biometrie + Quest-Engine + Skillbäume
Methodik: Entscheidungslogik basierend auf Zielprioritäten, Kontext, Zustand, Risiko/Chance und Hinweisbudget
Innovation: Brücke von Information > Verhalten > Identität über Training statt Motivation