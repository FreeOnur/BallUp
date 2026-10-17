# Kosten

> Was BallUp kostet – einmalig, laufend und pro Nutzer – und wo die echten Zahlen gemessen werden.
> **Stand:** 2026-10-11. Preise ändern sich (Hetzner hat 2026 zweimal erhöht): vor jeder Buchung beim Anbieter prüfen.
> Grundlage: Notion „Business Model“, „External Services“, „Skalierung & Backups“, „Unternehmensstruktur“.

## Rahmen

| Regel | Wert |
|---|---|
| Budget externe Dienste | max. **300 € / Monat** (Notion „External Services“) |
| Rechtsform | Einzelunternehmen „Onur Arslan“, Marke BallUp, Kleinunternehmerregelung (bis 55.000 € Umsatz/Jahr keine USt) |
| Grundsatz | Fixkosten müssen von Abos gedeckt sein, bevor Geld in Marketing fließt |
| Kostenstelle | Eigener Topf „Ballup“ mit eigener Karte im Geschäftskonto, alle BallUp-Abos laufen darüber |

## 1. Einmalige bzw. jährliche Kosten

| Posten | Kosten | Wann | Status |
|---|---|---|---|
| Google Play Developer | 25 $ einmalig | vor dem ersten Android-Release | offen |
| Apple Developer Program | 99 $ / Jahr (≈ 8,25 $ / Monat) | vor TestFlight / App Store | offen |
| Domain `ballup.eu` | laut Rechnung eintragen | jährlich | ✅ aktiv |
| Steuerberater Erstgespräch | laut Angebot | vor Gewerbeanmeldung | offen |
| Anwalt: Datenschutzerklärung + AGB | laut Angebot | vor Launch (Launch-Readiness) | offen |

## 2. Laufende Fixkosten (Stufe 0: < 1.000 Nutzer)

| Posten | Kosten / Monat (netto) | Ab wann | Status |
|---|---|---|---|
| Hetzner Cloud Server (2 vCPU, 4 GB, Falkenstein) | **3,90 €** (Abbuchung laut Nexus Finanz) | jetzt | ✅ läuft |
| Hetzner Server-Backups (Snapshot, optional) | +20 % des Serverpreises | jetzt empfohlen | offen |
| Hetzner Object Storage (Medien, ADR 0013) | 6,49 € inkl. 1 TB Speicher + 1 TB Traffic | ab erstem Upload-Feature | offen |
| Hetzner Storage Box BX11 (DB-Backups) | ca. 3,20 € (1 TB) | ab Datenbank in Produktion | offen |
| Google Workspace (E-Mail, `@ballup.eu` als Alias) | ≈ 6 € – geteilt mit allen Marken, für BallUp 0 € extra | läuft | ✅ |
| Geschäftskonto | 0–14 € je nach Anbieter (siehe unten) | ab Gewerbeanmeldung | offen |
| GitHub (öffentliches Repo) | 0 € | – | ✅ |
| Docker Hub (1 privates Repository) | 0 € | – | ✅ |
| Mapbox (bis 25.000 aktive Nutzer / Monat) | 0 € | ab Karten-Feature | offen |
| Resend (bis 3.000 Mails / Monat, 100 / Tag) | 0 €, danach 20 $ für 50.000 | ab Auth (Passwort-Reset) | offen |

**Summe Stufe 0, sobald alles läuft:** ca. **25–40 € / Monat** (Server, Object Storage, Storage Box, Apple-Anteil, Domain, Bank).

## 3. Variable Kosten pro Nutzer

### KI (Mistral, ADR 0015) – nur Premium, kommt nach den Core-Features

| Modell | Input | Output |
|---|---|---|
| Mistral Small 4 | 0,15 $ / 1 Mio. Tokens | 0,60 $ / 1 Mio. Tokens |

Grobe Rechnung pro Premium-Nutzer und Monat (1 Trainingsplan, 30 Trainer-Nachrichten, 20 Wurfanalysen,
Gelenkpunkte nur als Text): ca. 70.000 Input- und 17.000 Output-Tokens → **≈ 0,02 $**.
Notion rechnet vorsichtiger mit **≈ 0,05 $**, mit einem 10× teureren Modell ≈ 0,50 $.

**Schutz gegen Verluste** (Notion „Business Model“): max. 50 KI-Nachrichten pro Tag, Wurfanalysen gedeckelt,
Gratis-Nutzer ohne KI-Training, **Alarm, wenn ein Nutzer > 1 € im Monat verursacht**.

### Weitere

| Posten | Kosten | Wann relevant |
|---|---|---|
| Speicher pro Nutzer (Profilbild, Court-Fotos) | im Object-Storage-Paket enthalten bis 1 TB | ab Uploads |
| E-Mails über 3.000 / Monat | 20 $ / Monat für 50.000 | ab ~3.000 aktiven Nutzern |
| CDN (Bunny) | 0,01 $ / GB | ab Stufe 2 (~10.000 täglich aktive Nutzer) |
| Mapbox über 25.000 aktive Nutzer / Monat | laut Mapbox-Preisliste | ab Stufe 2 |

## 4. Einnahmen pro Premium-Abo

| Posten | Betrag |
|---|---|
| Abo-Preis (brutto) | 8,00 € / Monat |
| − 20 % USt (AT, führt der Store ab) | ≈ 6,67 € |
| − 15 % Store-Gebühr (Small Business Program Apple / Google) | **≈ 5,67 € pro Abo** |
| − KI-Kosten | ≈ 0,02–0,05 € |

**Break-even Stufe 0:** 25–40 € Fixkosten ÷ 5,67 € ≈ **5–7 Premium-Abos**.

## 5. Stufen (Notion „Skalierung & Backups“)

| Stufe | Auslöser | Was dazukommt | Kosten |
|---|---|---|---|
| 0 | jetzt (< 1.000 Nutzer) | 1 Server, tägliches Backup + WAL-Archiv | siehe oben |
| 1 | ~1.000 täglich aktive Nutzer oder CPU dauerhaft > 60 % | eigener DB-Server + Replica an zweitem Standort, Staging-Server | beim Erreichen neu kalkulieren |
| 2 | ~10.000 täglich aktive Nutzer | 2+ API-Server, Load Balancer, Lese-Replica, CDN | beim Erreichen neu kalkulieren |

## 6. Wie die echten Kosten gemessen werden

| Was | Wo | Wie |
|---|---|---|
| **KI-Kosten pro Nutzer** | Tabelle `ai_usage` (ADR 0015) | Jeder KI-Aufruf schreibt `user_id`, `feature` (Trainingsplan, Trainer, Wurfanalyse), `model`, `input_tokens`, `output_tokens`, `cost_eur`, `created_at`. Kosten werden beim Aufruf aus Tokens × aktuellem Preis berechnet. |
| **KI-Auswertung** | Grafana-Dashboard „KI-Kosten“ | Kosten pro Tag, pro Feature, Top-Nutzer, Kosten pro Premium-Nutzer im Monat. Alarm bei > 1 € pro Nutzer / Monat. |
| **Limits** | Backend (`ai_usage` + Redis-Zähler) | Request wird abgelehnt, wenn das Tages-/Monatslimit erreicht ist. |
| **Abos / Einnahmen** | Store-Webhooks → Tabelle `subscriptions` | Aktive Abos, Kündigungen, Umsatz pro Monat im Grafana-Dashboard „Business“. |
| **Infrastruktur** | Rechnungen der Anbieter | Einmal im Monat in die Tabelle unten eintragen. |

## 7. Ist-Kosten (monatlich nachtragen)

| Monat | Server | Object Storage | Storage Box | KI | E-Mail | Sonstiges | Summe | Premium-Abos |
|---|---|---|---|---|---|---|---|---|
| 2026-10 | 3,90 € | – | – | – | – | Domain | | 0 |

## 8. Geschäftskonto

Für das Töpfe-System aus Notion („Eingang“, „Steuern & SVS“, „Ballup“, „Puffer“, …):

| Anbieter | Kosten / Monat | Töpfe | IBAN | Passt für BallUp |
|---|---|---|---|---|
| **bunq Business** | Free 0 € (nur Einzelunternehmer, 3 Unterkonten) · Pro 13,99 € (25 Unterkonten) | jedes Unterkonto mit eigener IBAN, automatische Verteilung | NL / DE | **beste Abbildung der Töpfe** |
| **Revolut Business** | ab 10 € (Basic, 10 SEPA-Überweisungen inkl.), Grow 35 € | Unterkonten + viele virtuelle Karten | LT | gut, wenn du Revolut schon nutzt |
| **easybank easy business pro** | 9 € (20 SEPA-Überweisungen inkl.) | kaum Unterkonten | **AT** | wenn eine österreichische IBAN wichtig ist |

Eine ausländische EU-IBAN muss in Österreich laut SEPA-Verordnung überall akzeptiert werden
(Finanzamt, SVS, Kunden). Kostenloser Einstieg: **bunq Free**, Umstieg auf Pro, sobald mehr Töpfe nötig sind.
Vor der Eröffnung mit dem Steuerberater abstimmen.
