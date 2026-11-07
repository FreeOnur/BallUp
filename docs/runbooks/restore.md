# Runbook: Datenbank-Backup und Wiederherstellung

> Schritt-für-Schritt-Anleitung für den Betrieb (Deploy, Rollback, Backup-Restore, Incident …).
> So schreiben, dass es nachts um 3 Uhr ohne Vorwissen funktioniert.

## Ziele

| | Ziel | Woher es kommt |
|---|---|---|
| **RPO** (höchstens so viel Datenverlust) | **24 Stunden** | nächtlicher `pg_dump` um 03:30 (Wiener Zeit) + tägliches Hetzner-Backup |
| **RTO** (spätestens dann wieder online) | **4 Stunden** | Weg A in ca. 30 min, Weg B in ca. 2–3 h |

- **Wann nutzen:** Datenbank kaputt oder Daten versehentlich gelöscht (Weg A oder C), Server weg oder nicht mehr startbar (Weg A, sonst B),
  monatlicher Restore-Test, Backup-Alarm auf dem Handy
- **Braucht:** Tailscale, `ssh ballup` (onur, Schlüssel `privat_server`), sudo-Passwort und die Notiz „BallUp – Server .env“ aus Bitwarden,
  Zugang zur Hetzner Console

> **Vor jeder großen Server-Änderung** (Ubuntu-Upgrade, Firewall/SSH, Docker, Postgres-Version, Umbau am Compose-Stack):
> Hetzner Console → Server → **Snapshots** → Snapshot anlegen, Name z. B. `vor-<änderung>-2026-11-07`.
> Dauert 1–5 Minuten und kostet ein paar Cent im Monat. Danach alte Snapshots wieder löschen.

## Was gesichert wird

| Was | Wo | Wie oft, wie lange |
|---|---|---|
| Datenbank (`pg_dump -Fc`, geprüft) | `/var/backups/ballup/ballup-<datum>-<uhrzeit>.dump` auf dem Server, nur root | jede Nacht 03:30, 14 Tage, der neueste gute bleibt immer |
| ganzer Server (Image) | Hetzner-Backups | täglich, 7 Stück (Hetzner-Standard) |
| `.env` (alle Passwörter und Schlüssel) | Bitwarden, sichere Notiz „BallUp – Server .env“ | bei jeder Änderung von Hand aktualisieren |

Die Dumps liegen auf derselben Platte wie die Datenbank. Gegen „Server weg“ hilft nur das Hetzner-Backup,
bis es eine Kopie außerhalb des Servers gibt (eigene Festplatten oder Object Storage).

### So läuft das nächtliche Backup

`ballup-db-backup.timer` startet `/usr/local/sbin/ballup-db-backup` (Quelle: `deploy/scripts/server/backup-db.sh`):

1. `pg_dump -Fc` im Container `postgres`, erst in eine `.tmp`-Datei.
2. Prüft: `pg_restore --list` kann das Archiv lesen, die Tabelle `alembic_version` ist drin, und die Datei ist
   mindestens 50 % so groß wie der letzte gute Dump. Sonst heißt sie `*.dump.verdacht` und zählt nicht als gut.
3. Erfolg: Aufruf von `BACKUP_PUSH_URL`, der Uptime-Kuma-Monitor „DB-Backup nachts“ bleibt grün.
4. Fehler: Alarm an `NTFY_URL` mit kurzem Grund, Exit-Code 1.
5. Löscht Dumps älter als 14 Tage, nie den neuesten guten.

Bleibt der Push 25 Stunden aus (Server aus, Timer kaputt, Skript hängt), meldet Uptime Kuma das selbst.

### Einrichten oder aktualisieren

1. **Uptime Kuma** (`npm run tunnel:status`, `http://localhost:3001`): Neuer Monitor → Typ **Push**,
   Name `DB-Backup nachts`, Intervall **90000** Sekunden (25 h), Wiederholungen 0, ntfy-Benachrichtigung an. Speichern.
2. Die angezeigte Push-URL kopieren und den Teil vor `/api/push/` durch `http://127.0.0.1:3001` ersetzen
   (Kuma ist nur lokal erreichbar). Ergebnis: `http://127.0.0.1:3001/api/push/<token>?status=up&msg=OK&ping=`.
   In Bitwarden speichern (z. B. in die .env-Notiz).
3. Auf dem Server (`ssh ballup`): `sudo nano /opt/ballup/deploy/compose/.env`, Zeile `BACKUP_PUSH_URL=<url>` eintragen.
4. Im Repo-Root: `npm run sync`
5. Auf dem Server: `sudo bash /opt/ballup/deploy/scripts/server/install-backup.sh`
   (darf mehrfach laufen, ersetzt das alte Skript, die Sicherung liegt unter `/root/*.vor-install`).
6. Testlauf:
   ```bash
   sudo systemctl start ballup-db-backup.service
   journalctl -u ballup-db-backup -n 20 --no-pager      # "ok: ..." und "Push an Uptime Kuma gesendet"
   sudo /usr/local/sbin/ballup-db-backup --fehlertest    # ntfy-Alarm muss aufs Handy kommen
   ```
   In Uptime Kuma ist der Monitor jetzt grün.

## Monatlicher Restore-Test (ca. 5 Minuten)

Am ersten Wochenende im Monat:

```bash
ssh ballup
sudo bash /opt/ballup/deploy/scripts/server/restore-test-db.sh
```

Das Skript spielt den neuesten Dump in einen Wegwerf-PostGIS-Container ohne Netzwerk ein, zählt Tabellen und Zeilen
und löscht den Container wieder. Die Live-Datenbank wird nicht angefasst. Am Ende muss `RESTORE-TEST OK` stehen.
Die Zahlen grob mit der App vergleichen (z. B. Anzahl Nutzer). Einen bestimmten Dump testen: Pfad als Argument anhängen.

## Weg A: Hetzner-Backup oder Snapshot zurückspielen (ca. 30 min)

Für: Server startet nicht mehr, kaputtes Update, Server-Konfiguration verbastelt.
Datenstand = Zeitpunkt des Backups oder Snapshots, also bis zu 24 h alt.

1. Hetzner Console → Server `ballup` → **Backups** (oder **Snapshots**) → den passenden Stand wählen.
2. Vorher, wenn der Server noch läuft und die Daten danach wichtig sind: den neuesten Dump sichern
   (siehe „Dump vom Server holen“ unten). Sonst sind die Änderungen seit dem Backup weg.
3. **Wiederherstellen** → bestätigen. Der Server wird überschrieben und neu gestartet, IP und Tailscale-Name bleiben.
4. Weiter mit „Prüfen, ob alles geht“.

## Weg B: Neuer Server von null (ca. 2–3 h)

Für: Server gelöscht, Hetzner-Projekt weg, Backups unbrauchbar. Braucht einen Dump außerhalb des alten Servers
oder ein Hetzner-Backup, aus dem man einen Dump holen kann.

1. **Server anlegen:** Hetzner Console → Server hinzufügen, CX23, Ubuntu (gleiche Version wie bisher),
   eigenen SSH-Schlüssel `privat_server` hinterlegen, Firewall `ballup-firewall` zuweisen (nur 80/443, für die Einrichtung kurz TCP 22).
   Backups einschalten.
2. **Users:** als root anmelden, `adduser onur` (Passwort aus Bitwarden „BallUp Server – onur sudo“), `usermod -aG sudo onur`,
   Schlüssel nach `/home/onur/.ssh/authorized_keys`. `adduser --disabled-password deploy`, Deploy-Schlüssel nach
   `/home/deploy/.ssh/authorized_keys`.
3. **Docker:** `curl -fsSL https://get.docker.com | sh`, dann `usermod -aG docker deploy`.
4. **Ordner:** `mkdir -p /opt/ballup && chown deploy:deploy /opt/ballup`
5. **Tailscale:** `curl -fsSL https://tailscale.com/install.sh | sh`, `tailscale up --hostname=ballup-server`, mit dem BallUp-Konto bestätigen.
   Den alten Eintrag `ballup-server` in der Tailscale-Admin-Seite vorher löschen, sonst heißt der neue `ballup-server-1`.
   Bei „Disable key expiry“ den Haken setzen.
6. **Dateien:** im Repo-Root auf dem eigenen Rechner `npm run install:server` (kopiert alles, legt `.env` aus `.env.example` an).
7. **.env:** `npm run ssh`, `nano .env`, den Inhalt der Bitwarden-Notiz „BallUp – Server .env“ komplett einfügen. `chmod 600 .env`.
8. **Härten:** `sudo bash /opt/ballup/deploy/scripts/server/harden.sh`
9. **Nur Postgres starten:** `cd /opt/ballup/deploy/compose && docker compose up -d postgres`, warten bis `docker compose ps` „healthy“ zeigt.
10. **Dump einspielen:** Dump nach `/var/backups/ballup/` kopieren (siehe unten), dann:
    ```bash
    cd /opt/ballup/deploy/compose
    sudo cat /var/backups/ballup/<datei>.dump \
      | docker compose exec -T postgres sh -c 'pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" --clean --if-exists --no-owner --exit-on-error'
    ```
11. **Alles starten:** im Repo-Root `npm run deploy`.
12. **Backup einrichten:** Abschnitt „Einrichten oder aktualisieren“ oben, ab Schritt 5.
13. **DNS umstellen**, falls die IP neu ist: Hetzner Console → DNS → Zone `ballup.eu` → A-Records `@`, `www`, `api`, `status`
    auf die neue IP. In `.env.example` und in den Runbooks die IP anpassen (PR).
14. TCP 22 in der Hetzner-Firewall wieder löschen (siehe [Server-Zugang](server-zugang.md#4-port-22-schließen)).

## Weg C: Nur die Datenbank aus einem Dump zurückholen (ca. 15 min)

Für: Daten versehentlich gelöscht oder eine Migration hat Daten zerstört, der Server selbst ist in Ordnung.

1. Hetzner-Snapshot anlegen (siehe Kasten oben).
2. Erst mit dem Restore-Test prüfen, ob der Dump gut ist: `sudo bash /opt/ballup/deploy/scripts/server/restore-test-db.sh /var/backups/ballup/<datei>.dump`
3. API anhalten, damit niemand schreibt: `cd /opt/ballup/deploy/compose && docker compose stop api`
4. Aktuellen Stand zur Sicherheit dumpen: `sudo /usr/local/sbin/ballup-db-backup`
5. Einspielen wie in Weg B, Schritt 10 (`--clean --if-exists` ersetzt die bestehenden Objekte).
6. `docker compose start api`, dann „Prüfen, ob alles geht“.

## Dump vom Server holen

Vom eigenen Rechner (Tailscale an), z. B. vor Weg A oder für eine Kopie außerhalb:

```bash
ssh -t ballup 'f=$(sudo sh -c "ls -t /var/backups/ballup/ballup-*.dump | head -n1") && sudo install -o onur -m 600 "$f" ~/ballup-latest.dump'
scp ballup:ballup-latest.dump .
ssh ballup 'rm ~/ballup-latest.dump'
```

Auf einen neuen Server kommt die Datei umgekehrt: `scp ballup-latest.dump ballup:`, dann
`sudo install -D -m 600 ~/ballup-latest.dump /var/backups/ballup/ballup-latest.dump`.

Die Datei enthält alle Nutzerdaten: verschlüsselt ablegen (Bitwarden-Anhang, verschlüsselte Platte), nie ins Repo, nicht per Mail.

## Prüfen, ob alles geht

- `npm run status`: alle Container laufen, die API ist `healthy`.
- `https://api.ballup.eu/health` liefert `{"status":"ok"}`, `https://ballup.eu` lädt.
- In der App anmelden und eine Liste mit echten Daten öffnen.
- `docker compose run --rm api alembic current` zeigt dieselbe Version wie im Restore-Test.
- Uptime Kuma: alle Monitore grün. `systemctl list-timers ballup-db-backup.timer` zeigt den nächsten Lauf.

## Wenn es schiefgeht

- **ntfy „DB-Backup fehlgeschlagen“:** `journalctl -u ballup-db-backup -n 50 --no-pager` lesen.
  - *pg_dump fehlgeschlagen:* läuft `postgres`? `npm run status`, sonst `npm run deploy`. Danach `sudo systemctl start ballup-db-backup.service`.
  - *Dump nur … Bytes:* Wurden wirklich so viele Daten gelöscht? Wenn ja und gewollt:
    `sudo mv /var/backups/ballup/<datei>.dump.verdacht /var/backups/ballup/<datei>.dump`, dann ist das der neue Vergleichswert.
    Wenn nein: Weg C mit dem letzten guten Dump.
  - *keine Tabelle alembic_version:* `POSTGRES_DB` in der `.env` zeigt auf die falsche Datenbank.
- **Uptime Kuma meldet „DB-Backup nachts“ down, aber kein ntfy vom Skript:** Timer läuft nicht oder `BACKUP_PUSH_URL` stimmt nicht.
  `systemctl list-timers ballup-db-backup.timer`, `journalctl -u ballup-db-backup -n 20`, Push-URL mit
  `curl -fsS "<url>"` auf dem Server testen.
- **pg_restore bricht beim Restore-Test ab:** den Dump vom Vortag testen. Geht der, ist nur ein Dump kaputt. Gehen alle nicht: Notfall, Weg A
  mit Hetzner-Backup und sofort nachsehen, was am Backup-Skript nicht stimmt.
- **`RESTORE-TEST OK`, aber 0 Zeilen:** ist vor dem Launch normal (nur `alembic_version`). Nach dem Launch: falsche Datenbank, siehe oben.
