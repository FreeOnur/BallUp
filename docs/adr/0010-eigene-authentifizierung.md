# 0010 – Authentifizierung selbst gebaut, kein Identity-Provider

- **Status:** Akzeptiert
- **Datum:** 2026-10-10

## Kontext

Geplant war ein selbst gehosteter Identity-Provider (Zitadel oder Keycloak) unter `deploy/identity/`.
Für unsere Anforderungen (Google, Apple, E-Mail/Passwort, mobile Apps) ist das ein zusätzlicher,
schwergewichtiger Dienst mit eigenem Betrieb, eigener Datenbank und eigener UI.

## Entscheidung

Die Authentifizierung ist Teil des Backends (Modul `auth`). **Keine eigene Kryptografie** – nur
etablierte Bibliotheken und Standards.

- **Social Login:** OAuth 2.0 / OpenID Connect für **Google** und **Apple**. Das ID-Token wird
  **serverseitig** geprüft (Signatur über JWKS, `iss`, `aud`, `exp`, Nonce).
- **Access-Token:** eigenes JWT, Laufzeit **15 Minuten**.
- **Refresh-Token:** zufällig, in der Datenbank **nur als Hash** gespeichert, **Rotation** bei jeder
  Nutzung, **Diebstahl-Erkennung** (wird ein bereits rotiertes Token erneut benutzt, wird die ganze
  Token-Familie widerrufen).
- **Sitzungsdauer:** Abmeldung nach **30 Tagen Inaktivität** (gleitend – jede Nutzung verlängert).
- **Passwörter:** **Argon2id** mit Salt und **Pepper**. Der Pepper existiert nur als Server-Secret,
  nie in der Datenbank oder im Repo.
- **Passkeys** (WebAuthn) optional zusätzlich.
- **Warnung bei Login von neuem Gerät** (Push und/oder E-Mail).

## Alternativen

| Option | Warum nicht |
|---|---|
| Zitadel / Keycloak selbst gehostet | Eigener Dienst mit Betrieb, Updates und Datenbank – zu viel für den Funktionsumfang |
| Supabase Auth / Firebase Auth | Externer Anbieter, Daten außerhalb unserer Infrastruktur, Lock-in |
| Lange Access-Tokens ohne Refresh | Kein sauberer Widerruf, gestohlene Tokens bleiben lange gültig |

## Konsequenzen

- Positiv: Ein Dienst weniger, volle Kontrolle über Login-Flows und Daten.
- Negativ / Aufwand: Sicherheitskritischer Code liegt bei uns – Review nach
  [Security (MASVS)](../checklists/security-masvs.md) und Tests für alle Token-Pfade sind Pflicht.
- `deploy/identity/` entfällt.
