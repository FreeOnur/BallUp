# Guide: Mac mini einrichten (iOS-Entwicklung)

> Erklärt, **wie** man im Repo etwas macht (z. B. „Neues Feature-Modul anlegen“,
> „App auf echtem iPhone starten“, „Migration schreiben“).

Ziel: Auf dem Mac mini die iOS-App bauen, im Simulator und auf dem iPhone starten – und bei Bedarf auch
von dort deployen. Backend, Android und der geteilte Kotlin-Code gehen weiterhin auch unter Windows.

## Voraussetzungen

- Mac mini mit Apple Silicon (M1 oder neuer), aktuelles macOS
- Apple-ID; für TestFlight/App Store später das Apple Developer Program (99 $/Jahr)
- Zugang zum GitHub-Account `FreeOnur`

## Schritte

### 1. Xcode

1. **Xcode** aus dem Mac App Store installieren (groß, dauert).
2. Einmal öffnen, Lizenz akzeptieren, die zusätzlichen Komponenten installieren lassen.
3. Unter *Xcode → Settings → Components* die aktuelle **iOS-Simulator-Runtime** laden.
4. Im Terminal:
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   xcodebuild -version
   ```

### 2. Homebrew und Werkzeuge

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Die zwei "Next steps"-Zeilen ausführen, die der Installer am Ende ausgibt (PATH für /opt/homebrew).

brew install git gh xcodegen node
brew install --cask temurin@21       # JDK 21 – Xcode ruft beim Build Gradle auf (Kotlin-Framework "Shared")
java -version                        # muss 21 zeigen
```

Optional für Android auf dem Mac: `brew install --cask android-studio`.

### 3. GitHub und Repo

```bash
gh auth login                        # GitHub.com → HTTPS → im Browser als FreeOnur anmelden
gh auth setup-git
git config --global user.name  "<dein Name>"
git config --global user.email "<deine GitHub-E-Mail>"

mkdir -p ~/code && cd ~/code
git clone https://github.com/FreeOnur/BallUp.git
cd BallUp
```

### 4. iOS-Projekt erzeugen und starten

Das Xcode-Projekt wird aus `mobile/iosApp/project.yml` erzeugt und nicht committet ([ADR 0004](../adr/0004-xcodegen-statt-xcodeproj.md)).

```bash
cd mobile/iosApp
xcodegen generate
open BallUp.xcodeproj
```

In Xcode:

1. Links das Projekt **BallUp** → Target **BallUp** → **Signing & Capabilities**.
2. **Team** wählen (deine Apple-ID; vorher unter *Xcode → Settings → Accounts* hinzufügen).
   Das Team nie in `project.yml` eintragen, es bleibt lokal.
3. Oben einen Simulator wählen (z. B. iPhone 17) und **▶ Run** (⌘R).

Der erste Build dauert länger: Xcode startet Gradle und baut das Kotlin-Framework `Shared`.

**Nach jedem `git pull`**, wenn sich Dateien in `mobile/iosApp/` geändert haben: `xcodegen generate` erneut
ausführen. Build-Einstellungen nur in `project.yml` ändern, nicht in Xcode.

### 5. Auf dem eigenen iPhone starten

1. iPhone per Kabel anschließen, „Diesem Computer vertrauen“.
2. Auf dem iPhone: *Einstellungen → Datenschutz & Sicherheit → Entwicklermodus* einschalten (Neustart).
3. In Xcode oben das iPhone als Ziel wählen, ▶ Run.
4. Beim ersten Mal auf dem iPhone: *Einstellungen → Allgemein → VPN & Geräteverwaltung* → Entwickler-App vertrauen.

Ohne bezahltes Developer Program läuft die App 7 Tage, danach einfach erneut aus Xcode starten.

### 6. Geteilten Kotlin-Code testen

```bash
cd ~/code/BallUp/mobile
./gradlew iosSimulatorArm64Test
```

### 7. Vom Mac deployen (optional)

```bash
brew install --cask docker           # Docker Desktop, einmal starten
docker login -u onurballup           # Access Token mit Read & Write als Passwort
```

Den SSH-Schlüssel `ballup_deploy` (+ `.pub`) vom Windows-Rechner (`C:\Users\runolion\.ssh\`) nach `~/.ssh/`
kopieren, dann `chmod 600 ~/.ssh/ballup_deploy`. Danach im Repo-Root `npm run status` bzw.
`npm run deploy:api` – siehe [Runbook Deploy](../runbooks/deploy.md). Die Skripte bauen automatisch
`linux/amd64`, auch auf Apple Silicon.

## Häufige Probleme

- **„JAVA_HOME is not set“ / „Unable to locate a Java Runtime“ im Xcode-Build** – `brew install --cask temurin@21`,
  Xcode neu starten.
- **„No such module 'Shared'“ oder Framework nicht gefunden** – einmal Product → Clean Build Folder (⇧⌘K), dann ▶.
  Hilft das nicht: `cd mobile && ./gradlew :shared:umbrella:linkDebugFrameworkIosSimulatorArm64`.
- **„Xcode requested target architectures that are not configured in your Gradle build: ios_x64“** – es wurde
  „Any iOS Simulator Device“ gewählt; stattdessen einen konkreten Simulator auswählen.
- **„Signing for BallUp requires a development team“** – Schritt 4.2.
- **Projekt-Änderungen sind nach `git pull` weg oder fehlen** – `xcodegen generate` ausführen.
