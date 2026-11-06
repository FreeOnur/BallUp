# /.well-known

Wird unter `https://ballup.eu/.well-known/` ausgeliefert (Caddy, `deploy/caddy/Caddyfile`).

Hierher kommen, sobald die Apps signiert werden:

- `assetlinks.json` für Android App Links (Paket `eu.ballup`, SHA-256 des Signaturzertifikats aus der Play Console)
- `apple-app-site-association` (ohne Endung) für iOS Universal Links (Team-ID + `eu.ballup`)

Caddy liefert `apple-app-site-association` als `application/json` aus. Diese README selbst wird nicht ausgeliefert.
