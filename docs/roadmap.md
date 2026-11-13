# Roadmap

Where BallUp stands, what comes next and in which order. Sprints are 2 weeks ([workflow](guides/workflow.md)). Dates are a plan, not a promise: if a sprint slips, the following ones move. Issues in a sprint carry the label `sprint:<n>`.

Status on 2026-11-13: server, security, monitoring and backups are done. Backend skeleton with `/health` and force-update middleware. No feature code yet. Brand core and mascot style are decided, the rest of the design is open.

## Phases

| Phase | Content | Epics | Target |
|---|---|---|---|
| **1** | Foundations, login, profile, map and courts, moderation, platform, quality, legal, stores | #241 #177 #178 #179 #186 #185 #184 (friends/block) #191 #192 #193 #194 #242 | closed beta end of March 2027 |
| **2** | Games, matchmaking, ranking, chat | #180 #181 #184 (chat) | after Phase 1 beta |
| **3** | Crews, tournaments, clans, AI training, community, gamification, premium | #182 #183 #187 #188 #190 #189 | later |

## Phase 1 sprints

Each sprint is one vertical slice or a group of small ones (backend → shared → Android → iOS).

| Sprint | Dates | Goal | Issues |
|---|---|---|---|
| **1** | 16.11.–29.11.2026 | Apps start, talk to the API, show the force-update hint; website moved to `web/` with imprint | #216 Android skeleton · #217 iOS skeleton · #218 Ktor network layer · #219 SQLDelight · #220 error format · #160 force-update in the apps (M1–M3) · #174 imprint (part) · #173 move site to `web/` (part, ADR 0022) |
| **2** | 30.11.–13.12. | Sign up and sign in | #74 email + password · #75 Google · #76 Apple · #77 stay signed in · #78 reset password · #221 staging |
| **3** | 14.12.–27.12. | Safe accounts | #80 sessions · #81 new-device notice · #83 delete account · #84 export data · #90 youth protection 14–17 · #161 app integrity + rate limits |
| **4** | 28.12.–10.01.2027 | Profile and home | #85 onboarding · #86 own profile + settings · #87 other profile / player card · #88 avatar builder (needs #229) · #151 home screen |
| **5** | 11.01.–24.01. | Find courts | #92 courts on the map (+ clustering #14) · #93 filter · #94 search · #95 court details · #96 add a court · #97 approve courts |
| **6** | 25.01.–07.02. | Court community | #98 edit without overwriting · #99 photos · #100 rate · #101 favourite · #102 check in · #103 join a running game · #138 media review |
| **7** | 08.02.–21.02. | Friends and safety | #126 add friends · #127 block · #136 report · #137 moderator queue · #134 notification inbox · #135 push settings |
| **8** | 22.02.–07.03. | Platform | #156 offline read · #157 offline queue · #158 switch account · #159 live updates · #162 remote config · #163 analytics with consent · #164 crash reports |
| **9** | 08.03.–21.03. | Ready for beta | #165 accessibility · #166 German + English · #167 performance targets · #175 consents · #176 store rules · #238 store apps · #239 beta (TestFlight / Play internal) · #240 store listings |

Runs in parallel, not in a sprint slot: design and brand (#193, issues with `needs-decision`, decided by Onur), legal texts (#194), company and money (see [master checklist](checklists/master-checklist.md)).

## Dependencies to watch

- UI stories need design decisions: login screens #232, map/court screens #233, profile #234, home #235, states #236, colours #168, type #169. Foundation work uses a provisional theme until then.
- Avatar builder #88 needs the vector parts #229.
- Store accounts #238 need a company and a D-U-N-S number for "BallUp" as publisher.
- Load tests need staging #221.

## Phase 2 order (draft)

Games core (#21 create, #20 details, #22 location, #104 join/leave, #16 filter) → results (#110, #111, #117) → matchmaking and ranking (#113, #114, #17–#19, #115, #116, #118) → game extras (#105–#109, #112) → chat (#128, #129, #133) → stats #91, 2FA #82, passkeys #79.
