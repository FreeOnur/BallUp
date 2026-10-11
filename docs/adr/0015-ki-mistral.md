# 0015 – KI-Trainer: Mistral per API, Gelenkerkennung auf dem Gerät

- **Status:** Akzeptiert
- **Datum:** 2026-10-10

## Kontext

Der KI-Trainer analysiert Würfe und Bewegungen und gibt Tipps. Videos von Nutzern (oft Minderjährige)
sollen das Gerät nicht verlassen; die Kosten pro Nutzer müssen kontrollierbar bleiben.

## Entscheidung

- **Mistral** per API als Sprachmodell (EU-Anbieter).
- **Gelenkerkennung (Pose Estimation) läuft auf dem Gerät.** An die KI geht **nur Text**
  (z. B. extrahierte Winkel und Messwerte), keine Bilder oder Videos.
- **Limits pro Nutzer** (abhängig vom Abo); Verbrauch und Kosten werden in der Tabelle **`ai_usage`**
  protokolliert.
- Antworten werden per SSE gestreamt (0011).

## Alternativen

| Option | Warum nicht |
|---|---|
| Videos an ein multimodales Modell schicken | Datenschutz, Bandbreite und Kosten |
| Eigenes Modell hosten | GPU-Betrieb lohnt sich bei unserer Größe nicht |

## Konsequenzen

- Positiv: Datensparsam, Kosten pro Nutzer begrenzt und messbar.
- Negativ / Aufwand: Pose Estimation muss auf Android und iOS performant laufen; AVV mit Mistral nötig.
