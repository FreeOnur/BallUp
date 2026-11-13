# Master checklist

Everything BallUp still needs, code and non-code, in one list. Feature work is tracked in GitHub Issues (numbers below); this list links to them instead of repeating them. Order of coding: [roadmap.md](../roadmap.md). How we work: [guides/workflow.md](../guides/workflow.md).

Update rule: tick an item when it is done and add the date. Remove nothing; move finished sections to "Done" once in a while.

Status: 2026-11-13.

## ✅ Done

- **Server:** Hetzner CX23 in the BallUp account, delete protection, Hetzner backups, firewall only 80/443, SSH only via Tailscale (`ssh ballup`), keys only, no root login, fail2ban, sudo with password, automatic security updates, journal capped
- **Web security:** HTTPS with HSTS + HTTP/3, security headers, CAA, SPF, DKIM, DMARC `quarantine`, hardened containers with memory limits, Grafana and Uptime Kuma admin only via tunnel
- **Monitoring:** Prometheus, node-exporter, Grafana alerts (disk > 80 %, RAM > 85 %), Uptime Kuma (API, site, status page, certificate), phone alerts via ntfy
- **Backups (without disks):** checked nightly `pg_dump` with push to Uptime Kuma and ntfy alarm on failure, restore test script, [runbooks/restore.md](../runbooks/restore.md) (RPO 24 h, RTO 4 h), server `.env` in Bitwarden
- **Accounts:** 2FA everywhere, Bitwarden, recovery codes, Docker Hub private, old keys and tokens removed
- **Repo:** monorepo, CI for backend/Android/iOS, deploy scripts, Dependabot monthly, ADRs 0001–0022, agent team, ~150 issues with epics
- **Backend:** skeleton per ADR 0009, Postgres + PostGIS + Alembic, `/health`, force-update middleware (ADR 0021)
- **Brand:** brand core (target group 16–30, positioning, personality, mission, values, claim "Ball up, [place]."), mascot style (2000s Flash cartoon, boy + girl, 12 emotions, builder instead of AI generation) – Notion Design → Decisions
- **Planning:** this checklist, [workflow](../guides/workflow.md), [testing strategy](../guides/testing.md), [roadmap](../roadmap.md), sprint labels, issue templates

## 1. Now (Sprint 1: 16.–29.11.2026)

- [ ] Onur merges the planning PR
- [x] GitHub Project board "BallUp" created with all open issues (13.11.2026)
- [ ] Sprint 1 issues (label `sprint:1`): #216 #218 #219 #220 #160 #174 #173 (iOS #217 waits for a Mac) – details in [roadmap](../roadmap.md)
- [ ] Rebuild and deploy the API image after the certifi update (`npm run deploy:api`)
- [ ] Confirm the nightly backup ran (Uptime Kuma "DB-Backup nachts" green)
- [ ] 28.11.2026: read the DMARC reports

## 2. Coding setup

- [x] Monorepo layout decided; website goes to `web/` (ADR 0022)
- [x] Workflow: 2-week sprints, Definition of Ready/Done, labels, issue templates ([workflow](../guides/workflow.md))
- [x] Testing strategy ([testing](../guides/testing.md))
- [x] All new work in English
- [x] GitHub Project board "BallUp" (github.com/users/FreeOnur/projects/4): Todo / In Progress / Done, new repo issues are added automatically
- [ ] Mobile coverage tooling (Kover for shared/Android, Xcode coverage in ios-ci) #245
- [ ] Staging environment #221 (needed for load tests and safe testing)
- [ ] Mac mini (or Onur's Mac) for iOS ([guide](../guides/mac-mini-setup.md)); then work off the iOS catch-up list in #217
- [ ] Translate existing German docs and issue bodies to English when touched #244

## 3. Phase 1 features (see roadmap for sprints)

- [ ] Foundations #241: #216 #217 #218 #219 #220 #221
- [ ] Login & account #177: #74 #75 #76 #77 #78 #80 #81 #83 #84
- [ ] Profile, onboarding & avatar #178: #85 #86 #87 #88 #90
- [ ] Home #151
- [ ] Courts #179: #92 #14 #93 #94 #95 #96 #97 #98 #99 #100 #101 #102 #103
- [ ] Moderation #186: #136 #137 #138
- [ ] Notifications #185: #134 #135
- [ ] Friends & blocking: #126 #127
- [ ] Platform #191: #156 #157 #158 #159 #160 #161 #162 #163 #164
- [ ] Quality #192: #165 #166 #167

## 4. Testing and quality (ongoing)

- [ ] Every story: tests for each acceptance criterion, backend coverage ≥ 70 %
- [ ] First k6 load test against staging (after #221)
- [ ] Baseline Profiles + Macrobenchmark (Android), Instruments launch check (iOS) before the beta
- [ ] Real-device test round before the beta (device list in [testing](../guides/testing.md))
- [ ] Monthly security audit (skill `sicherheits-audit`)

## 5. Design and brand (Onur decides, issues in epic #193)

- [ ] Mascot finished: outfits, shoes, skin tones in Flash style, layers and colour slots, names, animation (Rive or Lottie) #222 #229 #172
- [ ] Design direction #223
- [ ] Colours #168 (own accent, not Strava/Nike), typography #169
- [ ] Logo, app icon, favicon #170
- [ ] Imagery, icons, 3D #224 · motion and haptics #225 · microcopy #226
- [ ] Map style and pins #171
- [ ] Design system components #227 and in code #228
- [ ] Screens: login/onboarding #232, map/courts #233, profile #234, home #235, states #236
- [ ] Applications: splash, store, social, e-mail, stickers #230 · brand guidelines #231

## 6. Website ballup.eu

- [ ] Move `deploy/site/` to `web/` (ADR 0022) #173
- [ ] Imprint (legally required now) #174
- [ ] Landing page in BallUp design with waitlist (API endpoint, consent) #173
- [ ] Privacy policy and terms pages #174

## 7. Legal and privacy (epic #194)

- [ ] Imprint, privacy policy, terms #174
- [ ] Consents (analytics, waitlist, push) #175
- [ ] Store guidelines check #176
- [ ] Trademark check "BallUp" + claims "Ball up, [place]." / "Wir sehen uns am Court." (Austrian Patent Office, EUIPO), register if free
- [ ] Data processing agreements: Hetzner, Google, Resend, Mapbox, Mistral, Apple/Google stores
- [ ] Go through [privacy-dsgvo.md](privacy-dsgvo.md)

## 8. Company and money

- [ ] Founders' agreement with Maurice (shares; code and brand belong to the project)
- [ ] WKO founder service appointment: legal form (GesbR or FlexCo), trade licence, small-business rule
- [ ] Joint account now, business account after founding; move all subscriptions
- [ ] Cost and budget plan for year one ([costs.md](../costs.md)), check grants (WISTO, aws)
- [ ] Collect all invoices in one Drive folder; one meeting with a tax adviser

## 9. Team and accounts

- [ ] Maurice: GitHub (second admin), Bitwarden organisation, Tailscale invite
- [ ] Apple Developer ($99/year) and Google Play ($25 once) – needs company + D-U-N-S for "BallUp" as publisher
- [ ] Secure social handles (`@ballup` / `@ballup.app`)
- [ ] Later: GitHub Team → organisation `ballup` → move repo → make it private

## 10. Release and stores (epic #242)

- [ ] Fix a beta date (draft: end of March 2027) and a public launch date
- [ ] Store apps #238, beta via TestFlight / Play internal #239, store listings #240
- [ ] Collect beta testers (friends, school, clubs) and a feedback channel
- [ ] Before the public launch: decide on Cloudflare in front of `ballup.eu` and the API (DDoS; needs DPA, DNS move, Caddy change)
- [ ] [launch-readiness.md](launch-readiness.md), [release.md](release.md), store checklists

## 11. Marketing and community

- [ ] Marketing plan: target groups, channels (Instagram, TikTok, Shorts, QR posters at courts, schools, local press), content plan, budget, launch campaign
- [ ] Waitlist: collect e-mails with consent, mail them at launch
- [ ] List of all basketball clubs in Vorarlberg + the state association; pitch and partnership offer; contact them once the beta is stable
- [ ] Press kit (logo, screenshots, short text, contact); KPIs (downloads, active users, retention day 7/30, subscriptions)

## 12. AI trainer (Phase 3, plan early)

Plan following ADR 0015 and the MindStudio checklist: exact use cases, one model per task, calls only through the backend, log model/tokens/cost per request, per-user cost cap (#155) and spike alerts, handle timeouts/broken output/refusals with a fallback, validate output against a schema, loading states or streaming, own evaluation cases, model swappable, start with one small feature (#139 #140).

## 13. Monthly routine (~30 min)

- [ ] Merge Dependabot PRs, `npm run deploy`, `npm run status`
- [ ] `nmap -Pn 46.224.171.6`: only 80 and 443 open
- [ ] Grafana: disk, RAM, CPU, slow queries
- [ ] DB restore test (`restore-test-db.sh`), entry in the backup test log
- [ ] Security audit

## 14. Later: backups with disks

- [ ] Pi on LAN and in Tailscale; disks A "BALLUP", B "PC", C "OFFLINE" (own power supply)
- [ ] Disk A nightly, encrypted (restic): DB dump, Docker volumes, Google Drive + Gmail, GitHub mirror, Notion export (monthly)
- [ ] Disk B: Veeam Agent nightly over LAN, recovery stick
- [ ] Disk C: monthly copy of A and B, unplug, keep off-site (3-2-1-1)
- [ ] Backup password in Bitwarden and on paper; monthly encrypted Bitwarden export to disk C; Pi runbook; Hetzner Storage Box after launch
- [ ] Backup tests: nightly (automatic), weekly `restic check`, monthly restore of one file per backup, quarterly test server from a Hetzner backup and boot from the Veeam stick, yearly "server gone" drill – each logged
