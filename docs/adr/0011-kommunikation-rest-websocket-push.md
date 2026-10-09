# 0011 – Kommunikation: REST, WebSocket im Vordergrund, Push, SSE

- **Status:** Akzeptiert
- **Datum:** 2026-10-10

## Kontext

Die App braucht normale Daten-Abfragen, ein paar Live-Ansichten und Benachrichtigungen, wenn die App
geschlossen ist. Dauerhafte Verbindungen kosten Akku und sind auf iOS im Hintergrund ohnehin nicht möglich.

## Entscheidung

- **REST** (`/v1`, `/admin/v1`) für alles, was keinen Live-Charakter hat – und als Quelle der Wahrheit.
- **WebSocket nur, solange die App im Vordergrund ist**, und nur für:
  Court live, Chat, Game-Belegung, Turnier-Bracket.
- Jedes Event trägt eine **Sequenznummer**. Verpasste Events (Verbindungsabbruch, App im Hintergrund)
  holt die App per **REST** nach („gib mir alles ab Sequenz N“).
- **Push** über **APNs** (iOS) und **FCM** (Android), wenn die App nicht offen ist.
- **Server-Sent Events (SSE)** für gestreamte Antworten des KI-Trainers.

## Alternativen

| Option | Warum nicht |
|---|---|
| WebSocket für alles | Mehr Komplexität, schlechter cachebar, Akku |
| GraphQL + Subscriptions | Zusätzlicher Stack; OpenAPI-Client (0003) passt besser zu REST |
| Polling für Live-Ansichten | Verzögerung und unnötige Last |

## Konsequenzen

- Positiv: Einfaches Grundmodell, Live-Features fallen bei Verbindungsproblemen sauber auf REST zurück.
- Negativ / Aufwand: Sequenznummern und Nachhol-Endpunkte müssen für jeden Live-Kanal gebaut werden.
