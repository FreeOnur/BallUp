# 0019 – App-ID `eu.ballup` statt `app.ballup`

- **Status:** Akzeptiert
- **Datum:** 2026-10-23

## Kontext

Android hieß `app.ballup`, iOS `app.ballup.ios`. Die Domain `ballup.app` gehört uns nicht, `ballup.eu` schon.
Eine App-ID lässt sich nach dem ersten Upload in den Play Store oder den App Store nicht mehr ändern.

## Entscheidung

Solange noch nichts in einem Store liegt, heißt die App-ID `eu.ballup`:

- Android: `applicationId` und `namespace` `eu.ballup`, Kotlin-Pakete `eu.ballup…`
- iOS: `eu.ballup.ios`, `eu.ballup.ios.tests`, `eu.ballup.ios.uitests` (XcodeGen, ADR 0004)
- SQLDelight und der generierte OpenAPI-Client unter `eu.ballup.shared…`

Deep Links bleiben `https://ballup.eu/…`.

## Konsequenzen

- Nach dem ersten Store-Upload ist diese ID fest.
- Auf dem Mac einmal `xcodegen generate` in `mobile/iosApp`, damit das Xcode-Projekt die neuen Bundle-IDs übernimmt. Unter Windows lässt sich die iOS-App nicht bauen.
