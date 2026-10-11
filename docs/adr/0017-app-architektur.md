# 0017 – App-Architektur: KMP für Data + Domain, native UI, MVVM

- **Status:** Akzeptiert
- **Datum:** 2026-10-10

## Kontext

0001 und 0005 legen den Build fest. Diese Entscheidung beschreibt, wie der Code innerhalb der Apps aufgebaut ist.

## Entscheidung

- **Kotlin Multiplatform** für **Data + Domain** (`mobile/shared/`), **UI nativ**:
  Jetpack Compose (Android), SwiftUI (iOS).
- **MVVM** mit **einem UI-State pro Screen** (unveränderliches State-Objekt, das der Screen rendert).
- **Use Cases nur für komplexe Logik**; einfache Fälle rufen das Repository direkt aus dem ViewModel auf.
- **Feature-Module** (`shared/feature/<feature>`, `androidApp/feature/<feature>`, `iosApp/BallUp/Features/<Feature>`).
- **SQLDelight** für die lokale Datenbank, **Koin** für Dependency Injection.
- **API-Client aus OpenAPI generiert** (0003).

## Alternativen

| Option | Warum nicht |
|---|---|
| Flutter | Keine native UI; hochwertige Animationen und Plattform-Feeling schwieriger |
| Compose Multiplatform auch für iOS | iOS-UI soll sich nativ anfühlen (SwiftUI-Animationen, Navigation) |
| MVI mit Reducer-Bibliothek | Mehr Zeremonie; ein UI-State pro Screen deckt den Nutzen ab |
| Use Case für jeden Aufruf | Viele Durchreiche-Klassen ohne Logik |

## Konsequenzen

- Positiv: Geschäftslogik und Daten einmal geschrieben, UI voll nativ.
- Negativ / Aufwand: Zwei UI-Codebasen; iOS konsumiert Kotlin-Code über das `Shared`-Framework.
