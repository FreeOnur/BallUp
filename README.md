# BallUp

**BallUp** ist eine App für Pickup-Basketball: Courts auf der Karte finden, Mitspieler und Gegner finden,
Games spielen, Ergebnisse melden und im Ranking aufsteigen – mit Teams, Turnieren, Chat, Community und Training.

- **Android:** Kotlin + Jetpack Compose · **iOS:** Swift + SwiftUI (beide nativ)
- **Geteilt:** Kotlin Multiplatform für Data + Domain (SQLDelight, Koin, Ktor, generierter OpenAPI-Client)
- **Backend:** FastAPI als modularer Monolith (REST `/v1`, `/admin/v1`, WebSockets), PostgreSQL + PostGIS, Redis-Jobs, eigene Auth (Google/Apple/Passwort)
- **Betrieb:** Hetzner + Docker Compose, Caddy, Prometheus/Grafana/Tempo, Uptime Kuma – alles selbst gehostet; Logs als JSON mit Docker-Log-Rotation
- **Dienste:** Mapbox (Karte), Hetzner Object Storage (Medien), Resend (E-Mail), Mistral (KI-Trainer)

Planung steht in **Notion** (Technical Planning), die Entscheidungen dazu in [`docs/adr/`](docs/adr/).
Überblick über die Doku: [`docs/README.md`](docs/README.md).

## Repo-Überblick

```
.
├── backend/            FastAPI-API (Python, uv)
│   └── src/ballup/     core/, shared/, api/, realtime/, workers/, dann ein Ordner pro Fachbereich
├── contracts/          openapi.json – Vertrag zwischen Backend und Apps
├── mobile/             EIN Gradle-Build für alles Mobile
│   ├── build-logic/    Convention Plugins (ballup.kmp.*, ballup.android.*)
│   ├── gradle/         libs.versions.toml (alle Versionen) + Wrapper
│   ├── shared/         Kotlin Multiplatform: core/* und feature/<feature> (data + domain), umbrella → iOS-Framework "Shared"
│   ├── androidApp/     app (Start, Navigation, Koin), core/{designsystem,ui}, feature/<feature> (Compose + ViewModels)
│   └── iosApp/         project.yml (XcodeGen) + BallUp/{App,Core,Features/<Feature>,Resources}
├── deploy/             compose/, caddy/, observability/, scripts/ – alles, was auf dem Server läuft
├── docs/
│   ├── architecture/   ER-Diagramm (draw.io) und weitere Diagramme
│   ├── adr/            Architecture Decision Records (Repo, Build, Stack, Architektur)
│   ├── checklists/     Launch-Readiness, Release, Store-Releases, Go-Live, Security/MASVS, DSGVO, Incident, neues Feature
│   ├── specs/          Feature-Specs (Vorlage _template.md)
│   ├── guides/         How-tos fürs Team
│   ├── runbooks/       Betriebsanleitungen (Deploy, Rollback, Restore, Incident)
│   ├── postmortems/    Incident-Auswertungen
│   └── design/         Design-System, Motion-Specs, Screens
├── .github/            CI (backend, android, ios), Deploy, Dependabot, CODEOWNERS, PR-Template
└── .devcontainer/      Codespace fürs Backend
```

Ein Fachbereich, ein Ordner, überall derselbe Name. Im Backend steht der Ordner im Singular
direkt unter `backend/src/ballup/` (ADR 0009). Tabellen bleiben Plural (`courts`, `games`).

| Bereich | Backend | Mobile |
|---|---|---|
| Account, Profil, Start | `auth`, `me`, `profile`, `home` | `auth`, `me`, `profiles`, `home` |
| Karte und Spiele | `court`, `upload`, `game`, `matchmaking`, `ranking` | `courts`, `uploads`, `games`, `matchmaking`, `rankings` |
| Mannschaften | `team`, `tournament`, `clan` | `teams`, `tournaments`, `clans` |
| Soziales | `social`, `chat`, `community`, `notification` | `social`, `chat`, `community`, `notifications` |
| Training und Kamera | `training`, `camera`, `gamification` | gleiche Namen |
| Moderation und Abo | `report`, `subscription` | `reports`, `subscriptions` |
| Nur Backend und Shared-Core | `telemetry`, `config` | `shared/core/telemetry`, `shared/core/config`, keine Screens |

Jeder Backend-Ordner hat `router.py`, `schemas.py`, `models.py`, `service.py`, `dependencies.py`,
`exceptions.py`, `constants.py`. Die Datenbank spricht nur der Service an. `court`, `profile`,
`chat`, `community` und `report` haben zusätzlich `admin_router.py`.

## Setup in 5 Minuten

### Backend

Voraussetzung: [uv](https://docs.astral.sh/uv/), Docker.

```bash
docker compose -f deploy/compose/compose.dev.yml up -d   # Postgres + Redis
cd backend
cp .env.example .env
uv sync
uv run alembic upgrade head
uv run ruff check . && uv run mypy && uv run pytest
uv run python scripts/export_openapi.py   # schreibt contracts/openapi.json, auch wenn /docs in Produktion aus ist
```

Oder ohne lokale Installation: **Code → Codespaces → Create codespace** (nutzt `.devcontainer/`).

### Android

Voraussetzung: Android Studio (aktuelle stabile Version, bringt JDK 21 mit).

1. `mobile/` in Android Studio öffnen und Gradle synchronisieren.
2. Run-Konfiguration **androidApp.app** starten.

```bash
cd mobile
./gradlew :androidApp:app:assembleDebug   # APK bauen
./gradlew spotlessApply                   # Code formatieren
./gradlew check                           # Tests + Lint
```

### iOS (nur macOS)

Voraussetzung: Xcode (aktuelle Version), JDK 21 (z. B. `brew install --cask temurin@21`), XcodeGen.

```bash
brew install xcodegen
cd mobile/iosApp
xcodegen generate
open BallUp.xcodeproj
```

In Xcode unter *Signing & Capabilities* dein Team wählen und starten. Der Build ruft Gradle auf und
baut dabei das Kotlin-Framework `Shared` automatisch. Ausführliche Einrichtung:
[Mac mini einrichten](docs/guides/mac-mini-setup.md).

## Deployen

Per Skript vom eigenen Rechner (wie SDX Eye, [ADR 0018](docs/adr/0018-deployment-per-skript.md)) –
braucht Docker, Node, Git und den SSH-Schlüssel `~/.ssh/ballup_deploy`:

```bash
npm run deploy:api            # API bauen, zu Docker Hub pushen, auf dem Server neu starten
npm run deploy                # ganzer Stack
npm run rollback -- <sha>     # auf ein früheres Image zurück
npm run status                # Container, Version, Health
npm run logs:api              # Logs live
```

Details und Fehlerbehebung: [Runbook Deploy](docs/runbooks/deploy.md).

## Mitarbeiten

Branches, Commits und PRs: siehe [CONTRIBUTING.md](CONTRIBUTING.md).
