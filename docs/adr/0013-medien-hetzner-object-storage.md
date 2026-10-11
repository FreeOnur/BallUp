# 0013 – Medien: Hetzner Object Storage mit Presigned URLs

- **Status:** Akzeptiert
- **Datum:** 2026-10-10

## Kontext

Nutzer laden Bilder und Videos hoch (Profil, Courts, Highlights). Die Dateien sollen nicht durch die
API laufen und möglichst bei demselben Anbieter wie der Server liegen.

## Entscheidung

- **Hetzner Object Storage** (S3-kompatibel) für alle Medien.
- **Upload per Presigned URL:** Die API stellt eine kurzlebige Upload-URL aus, die App lädt direkt in
  den Bucket, die API bestätigt danach den Upload.
- **CDN (Bunny)** erst ab etwa **10.000 täglich aktiven Nutzern**; bis dahin direkt aus dem Bucket.

## Alternativen

| Option | Warum nicht |
|---|---|
| Backblaze B2 | Weiterer Anbieter außerhalb von Hetzner; kein Vorteil bei unserer Größe |
| Supabase Storage | Bindet an Supabase, das wir nicht nutzen (0008) |
| Upload durch die API | Belastet API und Bandbreite unnötig |

## Konsequenzen

- Positiv: Alles bei einem Anbieter in der EU, einfacher AVV, API bleibt schlank.
- Negativ / Aufwand: Prüfung der hochgeladenen Dateien (Typ, Größe, Moderation) muss nach dem Upload passieren.
