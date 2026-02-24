### Schritte zur Aktivierung von Notion in OpenClaw:
1. **Installiere OpenClaw**:
   - Für macOS/Linux:
     ```bash
     curl -fsSL https://openclaw.ai/install.sh | bash
     ```
   - Für Windows (PowerShell):
     ```powershell
     iwr -useb https://openclaw.ai/install.ps1 | iex
     ```

2. **Führe den Onboarding-Assistenten aus**:
   ```bash
   openclaw onboard --install-daemon
   ```

3. **Überprüfe den Gateway-Status**:
   ```bash
   openclaw gateway status
   ```

4. **Öffne das Control UI**:
   ```bash
   openclaw dashboard
   ```

### Weitere Konfigurationen:
- Stelle sicher, dass die Umgebungsvariablen korrekt gesetzt sind, um die Integrationen und Konfigurationseinstellungen anzupassen.