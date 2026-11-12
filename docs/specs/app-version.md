# Feature-Spec: Force-Update für zu alte App-Versionen

- **Modul:** `core` (Backend); später Mobile `shared/core/network` + Update-Hinweis in beiden Apps
- **Status:** In Arbeit (Backend B1 umgesetzt, Mobile M1–M3 offen)
- **Notion:** [API-Design](https://www.notion.so/39d7fa3ccbe18025b22ad5c44bc3cb47) · Issue #160 · Epic #191

## Ziel

Kaputte oder unsichere App-Versionen abschalten, damit alle eine funktionierende Version nutzen. Regel aus Notion „API-Design“: Die App sendet ihre Version mit, bei zu alter Version antwortet die API mit `426 Upgrade Required`.

Dieser Schnitt baut **nur das Backend**. Der Update-Hinweis in der App ist eine eigene, spätere Aufgabe (siehe Aufgaben M1–M3).

- [ ] Erfolg: Mit `BALLUP_MIN_APP_VERSION_IOS=1.2.0` bekommt eine iOS-App mit `1.1.9` auf jeder API-Route `426`, eine App mit `1.2.0` normal `200`. `/health`, `/docs`, Web und `curl` ohne Header laufen weiter.

## User Stories & Akzeptanzkriterien

- Als Betreiber möchte ich pro Plattform eine Mindestversion setzen, damit ältere Apps gesperrt werden.
  - [ ] Mindestversion je Plattform über Umgebungsvariable, leer = keine Sperre
  - [ ] App-Version kleiner als Mindestversion → `426` im Fehlerformat `{"error": {"code": "app_version_too_old", "message": "…"}}`
  - [ ] Gleiche oder neuere Version → Anfrage läuft normal weiter
  - [ ] Ohne Versions-Header → erlaubt (Web, `curl`, Uptime Kuma, Deploy-Skript)
  - [ ] `/health`, `/docs`, `/redoc`, `/openapi.json` werden nie gesperrt, auch nicht mit alter Version
  - [ ] Ungültige Mindestversion in der Umgebung → API startet nicht (Fehlkonfiguration fällt sofort auf)
- Später (M1–M3): Als Spieler mit zu alter App sehe ich einen Update-Hinweis mit Store-Link.
- „Alte API-Version 6 Monate weiter unterstützt“ ist eine Betriebsregel, kein Code in diesem Schnitt (siehe Technische Entscheidungen).

## Screens & Zustände

Im Backend-Schnitt keine. Der Update-Hinweis kommt mit M2/M3, Design entscheidet Onur (offene Frage 1).

## Animationen & Interaktion

Entfällt im Backend-Schnitt.

## API

Kein neuer Endpunkt. Eine Middleware prüft jede HTTP-Anfrage.

| Header (Anfrage) | Werte | Pflicht |
|---|---|---|
| `X-App-Version` | `MAJOR.MINOR.PATCH`, nur Ziffern, z. B. `1.4.2` (= Android `versionName`, iOS `MARKETING_VERSION`) | nein |
| `X-App-Platform` | `ios` oder `android` (Groß/klein egal) | nein |

Prüfreihenfolge:

1. Pfad in `/health`, `/docs`, `/docs/oauth2-redirect`, `/redoc`, `/openapi.json` → durchlassen.
2. Kein `X-App-Version` → durchlassen.
3. `X-App-Version` nicht im Format `^\d{1,6}\.\d{1,6}\.\d{1,6}$` → `400`, Code `invalid_app_version`.
4. `X-App-Platform` fehlt oder unbekannt → durchlassen.
5. Keine Mindestversion für die Plattform gesetzt → durchlassen.
6. Version kleiner als Mindestversion (numerischer Vergleich, `1.10.0` > `1.9.0`) → `426`, Code `app_version_too_old`.
7. Sonst durchlassen.

Antwort bei `426`:

```json
{"error": {"code": "app_version_too_old", "message": "This app version is no longer supported. Please update."}}
```

Die App zeigt eigenen, übersetzten Text und reagiert auf Status + `code`, nicht auf `message`. `contracts/openapi.json` ändert sich nicht (keine neue Route).

## Daten

Keine Tabelle. Neue Einstellungen in `core/config.py`:

| Variable | Default | Bedeutung |
|---|---|---|
| `BALLUP_MIN_APP_VERSION_IOS` | `""` | Mindestversion iOS, leer = keine Sperre |
| `BALLUP_MIN_APP_VERSION_ANDROID` | `""` | Mindestversion Android, leer = keine Sperre |

Später kann die Mindestversion in `feature_flags.rules` (ER-Diagramm, Remote Config #162) wandern, damit sie ohne Neustart änderbar ist. Nicht in diesem Schnitt.

## Abhängigkeiten

- ADR 0009 (Struktur, Settings in `core/`), ADR 0011 (REST `/v1`), ADR 0019 (`eu.ballup`).
- Nichts muss vorher gebaut sein. Es gibt noch keine `/v1`-Route; Tests hängen eine Test-Route an.
- Mobile-Teil braucht den Ktor-Client in `mobile/shared/core/network` (heute leer) und #162 nicht.

## Technische Entscheidungen

- **Reine ASGI-Middleware** (`core/app_version.py`, Klasse `AppVersionMiddleware`), nicht `BaseHTTPMiddleware` und keine Router-Dependency. Grund: greift vor dem Routing, also auch für Routen, die es nicht mehr gibt (alte App bekommt `426` statt `404`), stört SSE (ADR 0011) nicht. Nur `scope["type"] == "http"`; WebSocket-Handshake prüft #159.
- **Kein Sicherheitsmerkmal.** Header lassen sich weglassen, deshalb „ohne Header = erlaubt“. Schutz vor fremden Clients ist #161 (App-Integrität).
- **Kein `Upgrade`-Header** in der `426`-Antwort. RFC 9110 sieht ihn für Protokollwechsel vor, hier gibt es keins. Bewusste Abweichung, wie in Notion festgelegt.
- **Eigener Versions-Parser** (Tupel aus drei Ints), keine neue Abhängigkeit (`packaging` ist nicht im Projekt).
- **Logging:** eine Zeile `app_version_rejected` (Plattform, Version, Mindestversion) bei `426`. Keine Nutzerdaten.
- **6 Monate alte API:** Kommt `/v2`, bleibt `/v1` mindestens 6 Monate. Danach wird die Mindestversion auf die erste App-Version gesetzt, die `/v2` nutzt, und erst dann `/v1` entfernt. Die Mindestversion setzt man in `deploy/compose/.env` auf dem Server, danach `npm run deploy:api`.

## Aufgaben

Eine Aufgabe, ein PR. Ablauf: [Features schneiden und bauen](../guides/ai-project-process.md).

- [x] **B1** #160 Force-Update-Middleware (Backend, umgesetzt) · `backend/src/ballup/core/app_version.py` (neu: `parse_app_version`, `AppVersionMiddleware`, `EXEMPT_PATHS`), `backend/src/ballup/core/config.py` (2 Felder + Validator), `backend/src/ballup/main.py` (Middleware einhängen), `backend/.env.example`, `deploy/compose/.env.example`, diese Spec · Tests `backend/tests/unit/core/test_app_version.py`: `test_parse_app_version_accepts_semver`, `test_parse_app_version_rejects_invalid` (parametrisiert: `""`, `1.2`, `1.2.3.4`, `v1.2.3`, `1.2.x`, 7-stellig), `test_versions_compare_numerically`, `test_old_version_gets_426_with_error_format`, `test_current_version_passes`, `test_newer_version_passes`, `test_missing_version_header_passes`, `test_missing_or_unknown_platform_passes`, `test_invalid_version_header_gets_400`, `test_no_min_version_configured_passes`, `test_platform_header_is_case_insensitive`, `test_health_and_docs_never_blocked`; in `backend/tests/unit/core/test_settings.py`: `test_settings_read_min_app_versions`, `test_settings_reject_invalid_min_app_version` · ca. 230 Zeilen Code + Tests, mit Spec ca. 340
- [ ] **M1** (später) Shared: Ktor-Client sendet `X-App-Version`/`X-App-Platform`, `426` → Zustand `UpdateRequired` · `mobile/shared/core/network/src/commonMain/kotlin/eu/ballup/shared/core/network/AppVersionPlugin.kt`, Versionswert aus `mobile/shared/core/config` · Test `commonTest/.../AppVersionPluginTest.kt` (`sendsVersionHeaders`, `maps426ToUpdateRequired`, `versionMatchesServerFormat`) · **blockiert:** Ktor-Grundgerüst in `core/network` fehlt noch
- [ ] **M2** (später) Android: Update-Hinweis mit Link `https://play.google.com/store/apps/details?id=eu.ballup` · `mobile/androidApp/core/ui/.../UpdateRequiredScreen.kt`, Einhängen in `mobile/androidApp/app/src/main/kotlin/eu/ballup/MainActivity.kt` · Test `UpdateRequiredScreenTest` (zeigt Hinweis bei `UpdateRequired`, Button öffnet Store) · **blockiert:** M1, Design (Frage 1)
- [ ] **M3** (später) iOS: Update-Hinweis mit App-Store-Link · `mobile/iosApp/BallUp/Core/UI/UpdateRequiredView.swift`, Einhängen in `mobile/iosApp/BallUp/App/BallUpApp.swift` · Test `mobile/iosApp/BallUpTests/UpdateRequiredViewModelTests.swift` · **blockiert:** M1, Design (Frage 1), App-Store-ID (Frage 3)

## Offene Fragen

Keine blockiert B1.

1. **Wie sieht der Update-Hinweis aus und was geht noch?** (Onur) A: Vollbild-Sperre, nichts geht mehr. B: Sperre, aber zwischengespeicherte Daten bleiben lesbar (passt zu „Offline lesen“ #156). Empfehlung: A, weil eine gesperrte Version ja kaputt oder unsicher ist. Blockiert M2/M3.
2. **Zusätzlich ein weicher Hinweis „Update empfohlen“** ohne Sperre? (Onur) Steht nicht in Notion. Empfehlung: erst einmal nein, später über Remote Config #162. Blockiert nichts.
3. **App-Store-ID für den iOS-Link** gibt es erst mit dem Eintrag in App Store Connect. Kein Entscheid, nur ein fehlender Wert. Blockiert M3.
4. **Fehlerformat im Rest der API:** Es gibt noch keinen globalen Handler. `HTTPException` antwortet heute mit `{"detail": …}`, nicht mit `{"error": {"code", "message"}}`. B1 baut die `426`/`400`-Antwort selbst im richtigen Format. Für den Rest braucht es eine eigene Aufgabe (eigenes Issue, nicht #160).
