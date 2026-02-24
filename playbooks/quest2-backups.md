# Quest 2 — GitHub + Google Drive Backups

Status: In Arbeit (started 2026-02-24)

## Ziel
Automatisierte, nachvollziehbare Backups für Workspace und kritische Artefakte mit Redundanz:
- GitHub (versionierte Config/Playbooks)
- Google Drive (zusätzliche Offsite-Kopie, verschlüsselt oder kontrolliert)

## Scope (Phase 1)
1. Backup-Inventar definieren (was ja/nein)
2. GitHub Push-Flow härten (branch + tags + retention)
3. Google Drive Upload-Flow aufsetzen (gog/drive)
4. Restore-Testplan erstellen

## Nächster Schritt
- `scripts/backup-inventory.sh` erzeugt Liste der zu sichernden Pfade + Exclusions.
