# 0012 – Karte: Mapbox, Plan B MapLibre + MapTiler

- **Status:** Akzeptiert
- **Datum:** 2026-10-10

## Kontext

Die Karte ist der Einstieg in die App (Courts finden). Sie muss gut aussehen, Satellitenbilder für
Courts bieten und offline nutzbar sein.

## Entscheidung

- **Mapbox** mit dem nativen **Maps SDK** auf Android und iOS.
- **Eigener Kartenstil** (BallUp-Look), **Satellit**-Ansicht, **Offline**-Karten.
- Ortssuche über die **Geocoding-API** mit **Debouncing** in der App – nicht die Search Box API
  (teurer, abrechnungsrelevante Sessions).
- **Plan B:** MapLibre (Open-Source-SDK) mit Kacheln von MapTiler, falls Kosten oder Lizenz nicht passen.

## Alternativen

| Option | Warum nicht |
|---|---|
| Google Maps | Weniger Freiheit beim Stil, Offline nur eingeschränkt |
| Apple Maps / Google Maps je Plattform | Zwei verschiedene Karten, uneinheitlicher Look |
| MapLibre + MapTiler sofort | Gute Option, aber Mapbox bietet aktuell das reifere SDK; bleibt Plan B |

## Konsequenzen

- Positiv: Einheitliche, hochwertige Karte auf beiden Plattformen.
- Negativ / Aufwand: Kosten pro Kartenaufruf beobachten; AVV mit Mapbox nötig (siehe Launch-Readiness).
