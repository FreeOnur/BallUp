# 0002 – `deploy/` statt `infra/`

- **Status:** Akzeptiert, teilweise ersetzt: `identity/` durch [0010](0010-eigene-authentifizierung.md), Loki/Alloy durch [0016](0016-observability-ohne-loki.md), Deploy-Ablauf (`backend-deploy.yml`, `git pull`) durch [0018](0018-deployment-per-skript.md)
- **Datum:** 2026-10-08

## Kontext

Wir betreiben einen Hetzner-Server mit Docker Compose (kein Kubernetes, kein Terraform). Der Ordner
enthält keine „Infrastruktur als Code“, sondern genau das, was auf dem Server läuft.

## Entscheidung

Der Ordner heißt `deploy/` und enthält:

- `compose/` – `compose.yml` (Produktion), `compose.observability.yml`, `compose.dev.yml` (lokal), `.env.example`
- `caddy/` – Reverse Proxy mit automatischem HTTPS
- `observability/` – Prometheus, Loki, Tempo, Alloy (Log-Versand), Grafana-Provisioning
- `identity/` – Identity-Provider (Zitadel oder Keycloak, noch offen)
- `scripts/` – Backup und Deploy-Hilfen

Der Server hat einen Checkout des Repos unter `/opt/ballup`; `backend-deploy.yml` macht dort `git pull`
und `docker compose pull && up -d`.

## Konsequenzen

- Selbsterklärender Name; wer deployen will, findet alles an einer Stelle.
- Kommt später echtes IaC (z. B. Terraform für Hetzner), bekommt es einen eigenen Unterordner `deploy/terraform/`.
