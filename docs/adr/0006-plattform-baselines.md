# 0006 – Plattform-Baselines (SDKs, Sprachversionen)

- **Status:** Akzeptiert
- **Datum:** 2026-10-08

## Entscheidung

| Bereich | Wert | Begründung |
|---|---|---|
| Android `minSdk` | 28 (Android 9) | Deckt den Großteil aktiver Geräte ab, moderne APIs ohne viel Compat-Code |
| Android `compileSdk` | 37 | Neueste stabile SDK-Plattform |
| Android `targetSdk` | 36 | Play-Store-Pflicht für neue Apps; Anhebung auf 37 als eigener PR nach Prüfung der Verhaltensänderungen |
| JVM-Bytecode | 17 | Standard für Android, Build läuft mit JDK 21 |
| iOS Deployment Target | 18.0 | `@Observable`, `phaseAnimator`/`keyframeAnimator`, Zoom-Navigation-Transitions, `MeshGradient` – die Basis für hochwertige Animationen |
| Swift | 6 (Strict Concurrency) | Aktueller Sprachmodus |
| Python | 3.14 | Aktuelle stabile Version, von allen Dependencies unterstützt |

## Konsequenzen

- Versionen stehen zentral in `mobile/gradle/libs.versions.toml`, `mobile/iosApp/project.yml` und
  `backend/pyproject.toml`; Dependabot hält Libraries aktuell.
