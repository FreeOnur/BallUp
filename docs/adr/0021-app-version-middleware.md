# 0021 – Mindest-App-Version als reine ASGI-Middleware vor dem Routing

- **Status:** Akzeptiert
- **Datum:** 2026-11-12

## Kontext

Kaputte oder unsichere App-Versionen sollen abgeschaltet werden (Notion „API-Design“, #160). Die App sendet `X-App-Version` und `X-App-Platform`, bei zu alter Version antwortet die API mit `426 Upgrade Required`. Die Prüfung muss jede API-Route treffen, auch Routen, die eine alte App noch aufruft, die es aber nicht mehr gibt. SSE (ADR 0011) darf nicht gestört werden. Details: [`docs/specs/app-version.md`](../specs/app-version.md).

## Entscheidung

- Reine ASGI-Middleware `AppVersionMiddleware` in `backend/src/ballup/core/app_version.py`, eingehängt in `main.py`. Kein `BaseHTTPMiddleware`, keine Router-Dependency.
- Prüft nur `scope["type"] == "http"`. Den WebSocket-Handshake prüft #159.
- `/health`, `/docs`, `/docs/oauth2-redirect`, `/redoc`, `/openapi.json` werden nie gesperrt.
- Ohne `X-App-Version`, ohne bekannte Plattform oder ohne gesetzte Mindestversion: durchlassen.
- Mindestversion je Plattform über `BALLUP_MIN_APP_VERSION_IOS` / `_ANDROID`, leer = keine Sperre. Ungültiger Wert: API startet nicht.
- Eigener Parser für `MAJOR.MINOR.PATCH` (Tupel aus drei Ints), keine neue Abhängigkeit.

## Alternativen

| Option | Warum nicht |
|---|---|
| FastAPI-Dependency pro Router | Greift erst nach dem Routing: entfernte Routen liefern `404` statt `426`. Jeder neue Router müsste daran denken |
| Prüfung im Reverse-Proxy | Mindestversion, Fehlerformat, Start-Prüfung und Tests lägen außerhalb des Backends. Die Spec sieht die Prüfung im Backend (`core/`) vor |

## Konsequenzen

- Positiv: Eine Stelle für alle HTTP-Routen. Alte Apps bekommen auch auf entfernten Routen `426` statt `404`, sehen also den Update-Hinweis.
- Ungültiger `X-App-Version`-Header ergibt `400` (`invalid_app_version`), nicht Durchlassen (Entscheidungs-Log, #202/#205). Formatfehler fallen beim Entwickeln auf, statt das Force-Update in Produktion still auszuhebeln. Bedingung: M1-Test `versionMatchesServerFormat`.
- Kein Sicherheitsmerkmal: Header lassen sich weglassen. Schutz vor fremden Clients ist #161.
- Die Middleware baut `426`/`400` selbst im Format `{"error": {"code", "message"}}`, weil es noch keinen globalen Fehler-Handler gibt.
- Mindestversion ändern braucht einen Neustart (`deploy/compose/.env`, `npm run deploy:api`). Später evtl. über Remote Config #162.
