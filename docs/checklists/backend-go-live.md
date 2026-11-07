# Backend Go-Live (Hetzner-Server)

## Server

- [ ] Ubuntu aktuell, automatische Sicherheitsupdates (`unattended-upgrades`)
- [ ] SSH nur mit Key, Root-Login und Passwort-Login aus, eigener Deploy-User
- [ ] SSH nur über Tailscale, Port 22 in der Hetzner-Firewall zu, `sudo` nur mit Passwort ([Runbook](../runbooks/server-zugang.md))
- [ ] Firewall: nur 22, 80, 443 offen (Hetzner Cloud Firewall + `ufw`)
- [ ] Docker + Compose-Plugin installiert, Repo unter `/opt/ballup` geklont
- [ ] `deploy/compose/.env` angelegt (aus `.env.example`), Rechte `600`

## DNS & TLS

- [ ] `ballup.eu`, `api.`, `status.ballup.eu` zeigen auf den Server
- [ ] Caddy hat Zertifikate geholt (HTTPS funktioniert, HTTP leitet um)
- [ ] Grafana nur per SSH-Tunnel (`npm run tunnel:grafana`), starkes Passwort, Sign-up aus

## CI/CD

- [ ] `main` per Ruleset geschützt (nur über PR, kein Force-Push), CI grün vor dem Merge
- [ ] Docker-Hub-Repository `onurballup/ballup-api` privat, Server per `docker login` (Read-only-Token) angemeldet
- [ ] Erster Deploy mit `npm run deploy` erfolgreich, Rollback mit `npm run rollback -- <sha>` getestet ([Runbook](../runbooks/deploy.md))
- [ ] Firewall: nur 22, 80, 443 offen (`ufw`), SSH nur mit Schlüssel

## Daten

- [ ] Datenbank entschieden, aufgesetzt, Migrationen laufen automatisch beim Deploy
- [ ] Tägliches Backup außerhalb des Servers (Object Storage, EU), verschlüsselt
- [ ] Restore auf frischem Server einmal durchgespielt und im Runbook dokumentiert

## Observability

- [ ] Prometheus scrapt die API, Grafana-Dashboards für Requests, Fehler, Latenz, Jobs
- [ ] Container loggen strukturiertes JSON, Docker-Log-Rotation aktiv (ADR 0016); Traces kommen in Tempo an
- [ ] Uptime-Kuma-Checks für API-Health, Benachrichtigung aufs Handy
- [ ] Alerts: API down, 5xx-Rate, Disk > 80 %, Zertifikat läuft ab
