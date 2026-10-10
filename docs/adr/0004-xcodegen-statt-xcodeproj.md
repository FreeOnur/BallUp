# 0004 – Xcode-Projekt per XcodeGen generieren, nicht committen

- **Status:** Akzeptiert
- **Datum:** 2026-10-08

## Kontext

`.xcodeproj`-Dateien sind schwer reviewbar und erzeugen bei mehreren Entwicklern ständig Merge-Konflikte.
Das Repo wurde unter Windows aufgesetzt, wo kein Xcode verfügbar ist.

## Entscheidung

- `mobile/iosApp/project.yml` (XcodeGen) beschreibt Targets, Bundle-IDs, Build-Settings und die
  Einbindung des KMP-Frameworks `Shared`.
- `*.xcodeproj/` steht in `.gitignore`. Lokal und in CI: `xcodegen generate`.
- Bundle-ID `app.ballup.ios`, Deployment Target iOS 18 (siehe 0006).

## Alternativen

| Option | Warum nicht |
|---|---|
| `.xcodeproj` committen | Merge-Konflikte, nicht reviewbar, nicht unter Windows erzeugbar |
| Tuist | Mächtiger, aber Swift-DSL und eigene Toolchain – für ein Team-Projekt dieser Größe Overkill |
| Reines Swift Package als App | Kein offizieller Weg für App-Targets mit Signing/Assets |

## Konsequenzen

- Neue Dateien in `BallUp/` werden automatisch aufgenommen (Ordner = Gruppen).
- Build-Settings ändert man in `project.yml`, nicht in Xcode, sonst sind sie beim nächsten Generieren weg.
