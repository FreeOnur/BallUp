# Path to release

The [master checklist](master-checklist.md) lists **everything** that is open. This page puts it **in order**: one stage after the other, from today to the public launch. Work through the top unticked stage; the next stage only starts when the "must be done" items of the current one are ticked.

- 🧑 = only Onur (or Maurice) can do it: decisions, accounts, money, legal, real-world contacts
- 🤖 = the agent team builds it (orchestrator → planner → builder → tester/reviewer/security → dokumentierer); Onur only merges or answers `question-for-onur`
- Issue numbers link to GitHub; sprint dates come from the [roadmap](../roadmap.md). If a sprint slips, the following stages slip too.

Status: 2026-11-14.

## How we build (short)

- **Vertical slices, not "all backend first".** One feature at a time through all layers: API contract (`contracts/openapi.json`) → backend → shared KMP → Android → (iOS). Each slice is usable on its own. Details: [workflow](../guides/workflow.md#order-of-work).
- **Inside a slice**, the contract comes first; then backend and app work can run in parallel because both build against the contract.
- **iOS waits for a Mac:** until there is one, the iOS part of each story goes onto the catch-up list in #217 ([roadmap](../roadmap.md#ios-waits-for-a-mac)).
- **Design runs one sprint ahead of code:** the screens a sprint needs must be decided before that sprint starts. Foundation work uses a provisional theme.
- **Design comes from the mascot:** mascot finished → design direction → colours and type → logo/icon → components → screens.

## Stage 0 – Clean up (14.11.2026)

- [x] Planning PR #246 and Orca session handover #247 merged (14.11.2026)
- [x] GitHub Project board "BallUp" with all open issues (13.11.2026)
- [x] API redeployed after the certifi update, healthy (14.11.2026)
- [x] Nightly backup ran successfully (systemd, 14.11.2026 03:30)
- [ ] 🧑 Merge #248 (mascot assets in `assets/maskottchen/aktuell/`)
- [ ] 🧑 Decide: should `tools/asset-sammler/` go into the repo? (10 MB `index.html` with embedded copies of the images – suggestion: keep it local)

## Stage 1 – Unblock the slow things (week of 16.11.)

These take weeks in the background, so they start now.

- [ ] 🤖 Imprint on ballup.eu #174 (legally required already now) → 🧑 check the company data and merge
- [ ] 🧑 Book the WKO founder service appointment (legal form GesbR or FlexCo, trade licence, small-business rule)
- [ ] 🧑 Founders' agreement with Maurice (shares; code and brand belong to the project)
- [ ] 🧑 Maurice: GitHub second admin, Bitwarden organisation, Tailscale invite
- [ ] 🧑 Secure social handles (`@ballup` / `@ballup.app`)
- [ ] 🤖 Trademark search "BallUp" + claims (Austrian Patent Office, EUIPO) → 🧑 decide whether to register
- [ ] 🧑 Plan the Mac (Mac mini or own Mac) – needed for iOS and the App Store ([guide](../guides/mac-mini-setup.md))

## Stage 2 – Sprint 1 (16.–29.11.): apps start + design direction

Code 🤖: #216 Android skeleton · #218 Ktor network layer · #219 SQLDelight · #220 error format · #160 force-update in the apps · #173 move website to `web/` · (#217 iOS waits for the Mac)

Design 🧑 decides, 🤖 designer proposes:
- [ ] Mascot open points #222: names of the two figures, Rive or Lottie, who draws the final figures
- [ ] Design direction #223 (based on the mascot; 3 proposals from the designer)
- [ ] Colours #168 and typography #169 (follow from the direction)
- [ ] Login and onboarding screens #232 (needed in Sprint 2)

Other:
- [ ] 28.11.: 🧑 read the DMARC reports
- [ ] 29.11.: 🧑 sprint review + planning Sprint 2

## Stage 3 – Sprint 2 (30.11.–13.12.): sign up and sign in

Code 🤖: #74 email + password · #75 Google · #76 Apple · #77 stay signed in · #78 reset password · #221 staging

Design 🧑/🤖:
- [ ] Logo, app icon, favicon #170
- [ ] Empty, loading and error states #236
- [ ] Mascot parts as final vectors #229 (needed in Sprint 4)

Company 🧑:
- [ ] Found the company at the WKO appointment, then **request the D-U-N-S number right away** (takes up to 30 days; without it no store accounts)
- [ ] Joint/business account, move all subscriptions to it
- [ ] 01.12.: first monthly routine (see below)

## Stage 4 – Sprint 3 (14.–27.12.): safe accounts

Code 🤖: #80 sessions · #81 new-device notice · #83 delete account · #84 export data · #90 youth protection 14–17 · #161 app integrity + rate limits

Design 🧑/🤖:
- [ ] Profile #234 and home #235 screens (needed in Sprint 4)
- [ ] Imagery/icons #224, motion and haptics #225, microcopy #226
- [ ] Design system components #227

Legal 🤖 drafts, 🧑 approves:
- [ ] Privacy policy and terms #174
- [ ] Data processing agreements: Hetzner, Google, Resend, Mapbox, Mistral
- [ ] Go through [privacy-dsgvo.md](privacy-dsgvo.md)

## Stage 5 – Sprint 4 (28.12.–10.01.2027): profile and home

Code 🤖: #85 onboarding · #86 own profile + settings · #87 player card · #88 avatar builder · #151 home · #228 design system in code

Design 🧑/🤖:
- [ ] Map/court screens #233 and map style + pins #171 (needed in Sprint 5)

Accounts 🧑 (as soon as the D-U-N-S number is there):
- [ ] Apple Developer ($99/year) and Google Play ($25 once) with "BallUp" as publisher
- [ ] Mac set up, iOS catch-up from #217 starts

## Stage 6 – Sprint 5 (11.–24.01.): find courts

Code 🤖: #92 courts on the map · #14 clustering · #93 filter · #94 search · #95 court details · #96 add a court · #97 approve courts

Money 🧑:
- [ ] Cost and budget plan year one ([costs.md](../costs.md)), check grants (WISTO, aws)
- [ ] All invoices in one Drive folder, one meeting with a tax adviser

## Stage 7 – Sprint 6 (25.01.–07.02.): court community

Code 🤖: #98 edit court · #99 photos · #100 rate · #101 favourite · #102 check in · #103 join a running game · #138 media review

Website and marketing:
- [ ] 🤖 Landing page with waitlist (API endpoint, consent) #173, consents #175
- [ ] 🧑 Marketing plan: target groups, channels (Instagram, TikTok, QR posters at courts, schools, local press), content plan, budget
- [ ] 🤖 List of all basketball clubs in Vorarlberg + the state association

## Stage 8 – Sprint 7 (08.–21.02.): friends and safety

Code 🤖: #126 add friends · #127 block · #136 report · #137 moderator queue · #134 notification inbox · #135 push settings

- [ ] 🤖 First k6 load test against staging
- [ ] 🧑 Collect beta testers (friends, school, clubs) and pick a feedback channel

## Stage 9 – Sprint 8 (22.02.–07.03.): platform

Code 🤖: #156 offline read · #157 offline queue · #158 switch account · #159 live updates · #162 remote config · #163 analytics with consent · #164 crash reports

- [ ] 🤖 Baseline Profiles + Macrobenchmark (Android), launch check (iOS)
- [ ] 🧑/🤖 Store listing texts and screenshots #240, store/social/e-mail assets #230

## Stage 10 – Sprint 9 (08.–21.03.): ready for the beta

Code 🤖: #165 accessibility · #166 German + English · #167 performance targets · #175 consents · #176 store rules · #238 store apps · #239 beta builds · #240 store listings

- [ ] 🧑 Real-device test round (device list in [testing](../guides/testing.md))
- [ ] 🤖 Security audit, [launch-readiness.md](launch-readiness.md)
- [ ] 🧑 Fix the beta date

## Stage 11 – Closed beta (end of March 2027)

- [ ] 🧑 Invite testers via TestFlight and Play internal testing
- [ ] 🤖 Collect feedback as issues, fix bugs in short loops
- [ ] 🧑 Fix the public launch date

## Stage 12 – Public launch

- [ ] 🧑 Decide on Cloudflare in front of `ballup.eu` and the API (DDoS; needs DPA, DNS move, Caddy change)
- [ ] 🤖 Brand guidelines #231, press kit (logo, screenshots, short text, contact), KPIs (downloads, active users, retention day 7/30)
- [ ] 🧑 Launch campaign, mail the waitlist, contact the clubs
- [ ] 🤖 [release.md](release.md), [app-store-release.md](app-store-release.md), [play-store-release.md](play-store-release.md) → 🧑 submit to the stores
- [ ] After launch: Phase 2 (games, matchmaking, ranking, chat – [roadmap](../roadmap.md#phase-2-order-draft))

## Every month (~30 min, from 01.12.2026)

- [ ] Merge Dependabot PRs, `npm run deploy`, `npm run status`
- [ ] `nmap -Pn 46.224.171.6`: only 80 and 443 open
- [ ] Grafana: disk, RAM, CPU, slow queries
- [ ] DB restore test (`restore-test-db.sh`), entry in the backup test log
- [ ] Security audit
