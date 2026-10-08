# Backend Go-Live (Hetzner-Server)

## Server

- [ ] Ubuntu aktuell, automatische Sicherheitsupdates (`unattended-upgrades`)
- [ ] SSH nur mit Key, Root-Login und Passwort-Login aus, eigener Deploy-User
- [ ] Firewall: nur 22, 80, 443 offen (Hetzner Cloud Firewall + `ufw`)
- [ ] Docker + Compose-Plugin installiert, Repo unter `/opt/ballup` geklont
- [ ] `deploy/compose/.env` angelegt (aus `.env.example`), Rechte `600`

## DNS & TLS

- [ ] `api.`, `grafana.`, `status.ballup.app` zeigen auf den Server
- [ ] Caddy hat Zertifikate geholt (HTTPS funktioniert, HTTP leitet um)
- [ ] Grafana nur mit starkem Passwort, Sign-up aus; optional per IP/SSO einschränken

## CI/CD

- [ ] GitHub Environment `production` mit Required Reviewers
- [ ] Variable `DOCKERHUB_USERNAME`, Secrets `DOCKERHUB_TOKEN`, `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_SSH_KEY`
- [ ] Erster Deploy über `backend-deploy.yml` erfolgreich, Rollback getestet (vorheriges `sha-…`-Image)

## Daten

- [ ] Datenbank entschieden, aufgesetzt, Migrationen laufen automatisch beim Deploy
- [ ] Tägliches Backup außerhalb des Servers (Object Storage, EU), verschlüsselt
- [ ] Restore auf frischem Server einmal durchgespielt und im Runbook dokumentiert

## Observability

- [ ] Prometheus scrapt die API, Grafana-Dashboards für Requests, Fehler, Latenz, Jobs
- [ ] Logs der Container kommen in Loki an, Traces in Tempo
- [ ] Uptime-Kuma-Checks für API-Health und Identity-Provider, Benachrichtigung aufs Handy
- [ ] Alerts: API down, 5xx-Rate, Disk > 80 %, Zertifikat läuft ab
