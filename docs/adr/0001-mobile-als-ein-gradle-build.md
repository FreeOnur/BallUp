# 0001 – `mobile/` als ein Gradle-Build statt `android/` + `ios/` auf Top-Level

- **Status:** Akzeptiert
- **Datum:** 2026-10-08

## Kontext

Android und iOS teilen sich Data + Domain über Kotlin Multiplatform. Der geteilte Code (`shared/`) wird
vom Android-App-Modul als Gradle-Projekt und von Xcode als Framework (`Shared`) konsumiert. Der
Gradle-Task, der das Framework baut, läuft aus dem Xcode-Build heraus (`embedAndSignAppleFrameworkForXcode`).

## Entscheidung

Alles, was zur App gehört, liegt unter `mobile/` in **einem** Gradle-Build:

- `mobile/shared/` – KMP-Module (core + feature), `umbrella/` exportiert das iOS-Framework
- `mobile/androidApp/` – Compose-UI, ViewModels, App-Modul
- `mobile/iosApp/` – SwiftUI-App, liest das Framework aus `shared/umbrella/build`
- `mobile/build-logic/` – Convention Plugins, `mobile/gradle/libs.versions.toml` – alle Versionen

Das entspricht der offiziellen JetBrains-Struktur (`shared` + `androidApp` + `iosApp` nebeneinander)
und der Modularisierung von „Now in Android“.

## Alternativen

| Option | Warum nicht |
|---|---|
| `android/`, `ios/`, `shared/` auf Top-Level | Drei Ordner, die nur zusammen funktionieren; Gradle-Root müsste trotzdem über allen liegen |
| Separate Repos | Contract-Änderungen bräuchten koordinierte PRs in mehreren Repos |

## Konsequenzen

- Ein `./gradlew` für alles Mobile, ein Version Catalog, gemeinsame Convention Plugins.
- iOS-Entwickler brauchen ein JDK, weil Xcode Gradle aufruft.
- CI-Pfadfilter: `android-ci` ignoriert `mobile/iosApp/**`, `ios-ci` reagiert zusätzlich auf `mobile/shared/**`.
