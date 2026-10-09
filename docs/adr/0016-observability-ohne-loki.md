# 0016 – Observability ohne Loki

- **Status:** Akzeptiert
- **Datum:** 2026-10-10

## Kontext

`deploy/compose/compose.observability.yml` enthielt Loki mit Alloy als Log-Versand. Für einen
einzelnen Server ist das ein weiterer Dienst mit Speicher- und Wartungsaufwand, ohne dass wir die
Log-Suche über Grafana aktuell brauchen.

## Entscheidung

- Selbst gehostet: **Grafana**, **Prometheus** (Metriken), **Tempo** (Traces), **Uptime Kuma** (Statusseite).
- **Logs** bleiben **strukturiertes JSON auf stdout**. Docker speichert sie mit dem `json-file`-Treiber
  und **Rotation** (`max-size: 50m`, `max-file: 10`) für jeden Service, gesetzt über einen YAML-Anker
  `x-logging` in allen Compose-Dateien. Lesen per `docker compose logs`.
- **Kein Loki**, kein Alloy.
- Zusätzlich eigene Lösungen für **Crash-Reporting**, **Analytics**, **Feature Flags** und **A/B-Tests**.

## Alternativen

| Option | Warum nicht |
|---|---|
| Loki + Alloy | Zusätzlicher Dienst und Speicher; aktuell kein Bedarf an zentraler Log-Suche |
| Externer Log-Dienst | Daten verlassen den Server, Kosten |

## Konsequenzen

- Positiv: Weniger Dienste, kein Log-Speicher, der volllaufen kann.
- Negativ / Aufwand: Keine Log-Suche in Grafana, kein Sprung von Traces zu Logs. Kommt der Bedarf,
  wird Loki per neuem ADR wieder aufgenommen.
- Teilweise ersetzt: die Angaben zu Loki/Alloy in [0002](0002-deploy-ordner-statt-infra.md).
