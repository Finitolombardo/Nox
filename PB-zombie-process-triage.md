## Playbook: PB-zombie-process-triage

### 1. Überprüfung auf Zombie-Prozess
- **Befehl**: `ps aux | awk '{ if($8 == "Z") print $1, $2, $3, $8, $11 }'`
- **Ergebnis**:  
   - PID: 3865642  
   - Zustand: Z (Zombie)  
   - Befehlsname: `[chrome-headless]`

### 2. Identifikation des Elternprozesses
- **Befehl**: `ps -p 3865642 -o ppid=`  
- **Ergebnis**:  
   - PPID: 3865405

### 3. Ermittlung des Dienstes/Containers
- **Befehl**: `ps -p 3865405 -o cmd=`  
- **Ergebnis**:  
   - Befehl: `npm start`

### 4. Remediationsoptionen
- Empfohlene Maßnahmen:
   - **Neustarten des Elternprozesses**:  
     ```bash
     npm restart
     ```

### 5. Verifikation
- Prüfe, ob der Prozess nach dem Neustart verschwunden ist:  
   ```bash
   ps aux | awk '{ if($8 == "Z") print $1, $2, $3, $8, $11 }'
   ```

### 6. Safety Note: Wann NICHT neu starten
- Wenn der Elternprozess kritische Aufgaben ausführt oder andere abhängige Prozesse hat, die nicht unterbrochen werden sollten.