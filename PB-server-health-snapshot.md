## Playbook: PB-server-health-snapshot

### 1. Uptime
- **Befehl**: `uptime`
- **Ergebnis**: 21:05:12 up 10 days, 5:04, 13 users, load average: 1.90, 2.85, 3.00

### 2. Disk Usage
- **Befehl**: `df -h /`
- **Ergebnis**:
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        38G   32G  4.0G  89% /
```

### 3. Memory Usage
- **Befehl**: `free -h`
- **Ergebnis**:
```
total        used        free      shared  buff/cache   available
Mem:            15Gi       3.4Gi       2.8Gi        29Mi       9.5Gi        11Gi
Swap:          4.0Gi       1.0Mi       4.0Gi
```

### 4. Docker Disk Usage
- **Fehler**: Kein Zugriff auf die Docker-API.

### 5. Journal Disk Usage
- **Ergebnis**: Archived and active journals take up 18.9M in the file system.

### 6. Key Observation
- Hauptrisiko: Die hohe Auslastung der Festplatte (89% belegt), was zu einem möglichen Speicherengpass führen könnte.