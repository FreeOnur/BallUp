# 0014 – E-Mail: Resend in der Region eu-west-1

- **Status:** Akzeptiert
- **Datum:** 2026-10-10

## Kontext

Wir brauchen transaktionale E-Mails (Bestätigung, Passwort zurücksetzen, Warnung bei neuem Gerät,
Datenauskunft).

## Entscheidung

- **Resend** als E-Mail-Dienst, Region **`eu-west-1`** (Daten in der EU).
- Versand aus dem Backend über einen Hintergrund-Job (Redis-Queue, 0008), nie blockierend im Request.

## Alternativen

| Option | Warum nicht |
|---|---|
| Eigener Mailserver | Zustellbarkeit (SPF/DKIM/Reputation) ist viel Aufwand |
| Amazon SES | Mehr Einrichtungsaufwand, schlechtere Developer Experience |

## Konsequenzen

- Positiv: Einfache API, gute Zustellbarkeit, EU-Region.
- Negativ / Aufwand: AVV mit Resend nötig; Domain mit SPF/DKIM/DMARC einrichten.
