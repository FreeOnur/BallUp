# 0003 – OpenAPI-Contract als Datei in `contracts/`

- **Status:** Akzeptiert
- **Datum:** 2026-10-08

## Kontext

Der API-Client der Apps wird aus der OpenAPI-Spec generiert (Notion). FastAPI erzeugt die Spec zur
Laufzeit. Die Apps sollen aber bauen können, ohne dass ein Server läuft.

## Entscheidung

- `contracts/openapi.json` ist die versionierte Spec und die **einzige** Quelle für den Client.
- Das Backend exportiert sie (Export-Skript kommt mit dem ersten Endpunkt), CI prüft später, dass
  Datei und Code übereinstimmen.
- `mobile/shared/core/network` generiert daraus mit dem OpenAPI Generator
  (`./gradlew :shared:core:network:openApiGenerate`, Generator `kotlin`, Library `multiplatform`).

## Konsequenzen

- API-Änderungen sind im PR-Diff sichtbar und reviewbar (CODEOWNERS für `contracts/`).
- Backend- und Mobile-CI reagieren beide auf Änderungen in `contracts/**`.
- Der generierte Code ist noch nicht in die `commonMain`-Sources eingehängt. Das passiert mit dem
  ersten echten Endpunkt, sobald geprüft ist, dass der generierte Code mit unserer Ktor-Version kompiliert.
