# 0005 – AGP 9 mit Android-KMP-Library-Plugin und getrennten App-Modulen

- **Status:** Akzeptiert
- **Datum:** 2026-10-08

## Kontext

Ab Android Gradle Plugin 9 ist das Kotlin-Multiplatform-Plugin nicht mehr mit `com.android.library` /
`com.android.application` kombinierbar. Kotlin ist in AGP 9 eingebaut („built-in Kotlin“).

## Entscheidung

- KMP-Module (`mobile/shared/**`) nutzen `com.android.kotlin.multiplatform.library` mit dem
  `kotlin { android { … } }`-Block (Convention Plugin `ballup.kmp.library`).
- Android-UI-Module sind reine Android-Module (`ballup.android.library`, `ballup.android.feature`) mit
  eingebautem Kotlin; das App-Modul (`ballup.android.application`) ist ein eigenes Modul.
- Gleichnamige Module (`:shared:feature:courts` und `:androidApp:feature:courts`) bekommen
  unterschiedliche Gradle-`group`s, damit die Dependency-Auflösung sie nie verwechselt.
- `ballup.android.feature` hängt automatisch von seinem Gegenstück `:shared:feature:<name>` ab.

## Konsequenzen

- Entspricht den aktuellen Migrations-Guides von JetBrains und Google, keine Legacy-Flags nötig.
- Quellordner im KMP-Android-Target: `androidMain`, `androidHostTest`, `androidDeviceTest`.
