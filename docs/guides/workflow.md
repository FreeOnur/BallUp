# How we work

The one page that says how BallUp is built: who does what, how work is planned, when something is "ready" and "done", and where things are written down. Details live in the linked files; this page does not repeat them.

## People

- **Onur** and **Maurice** both build everything ("whoever takes an issue builds it end to end"). Right now Onur does most of the work.
- An **AI agent team** (`.claude/agents/`) plans, builds, tests, reviews and documents. Roles and flow: [team/agents.md](../team/agents.md), [ADR 0020](../adr/0020-ki-entwicklungsteam.md).
- Onur decides product, design, money and anything risky. Questions go to him as issues with the label `question-for-onur`; Maurice may answer them for him.

## Language

From 2026-11-13 everything new is **English**: code, comments, commits, PRs, issues, specs, docs. Existing German docs and issue bodies are translated **when they are next touched** (tracking issue #244). Chat with Onur stays German.

## Where things live

| What | Where | Source of truth |
|---|---|---|
| Work items (stories, tasks, bugs) | GitHub Issues | ✅ |
| Plan: phases, sprints, order | [roadmap.md](../roadmap.md) | ✅ |
| Everything still to do (also non-code) | [checklists/master-checklist.md](../checklists/master-checklist.md) | ✅ |
| Current state of the code | [status.md](../status.md) | ✅ |
| Repo/build/code decisions | [adr/](../adr/) | ✅ |
| Product vision, stack overview, design and brand decisions | Notion (BallUp, Technical Planning, Design) | ✅ for product and design |
| What changed | [changelog/CHANGELOG.md](../changelog/CHANGELOG.md) | ✅ |

Rule: a fact is written in **one** place, everything else links to it.

## Issues

Every issue has:

| Label | Values |
|---|---|
| type | `user-story`, `epic`, `bug`, `documentation`, `security`, `idea`, `needs-decision`, `question-for-onur` |
| area | `area:<x>` (same names as the code folders, e.g. `area:auth`, `area:court`) |
| phase | `phase-1`, `phase-2`, `phase-3` (and the phase milestone) |
| priority | `prio:core`, `prio:later`, `prio:stretch` |
| sprint | `sprint:<n>` while it is planned for a sprint |

Title format: `<Area>: <what the user can do>` (e.g. `Login & Account: Sign in with Google`). A story body has: **Story** ("As a … I want … so that …"), **Acceptance criteria** (checklist), **Depends on**, **Definition of Done**. Templates: `.github/ISSUE_TEMPLATE/`.

## Sprints

- **2 weeks**, Monday to Sunday. Sprint 1 starts on 2026-11-16. Dates and content: [roadmap.md](../roadmap.md).
- **Planning** (Monday, 15 min): pick issues that are *ready* (see below), add `sprint:<n>`. Plan for what one person plus the agents can finish. Rather fewer.
- **During the sprint:** one issue at a time per person, end to end (see "Order of work").
- **Review + retro** (last Sunday, 15 min): what is done (closed issues), what moves to the next sprint, one thing to do better. Result as one entry in [team/sitzungen.md](../team/sitzungen.md).

## Definition of Ready

An issue may go into a sprint when:

- [ ] Story and acceptance criteria are clear and testable
- [ ] Dependencies are done or in the same sprint
- [ ] No open `needs-decision` / `question-for-onur` blocks it (design: a provisional theme is fine for foundation work)
- [ ] Small enough: the spec splits it into tasks of < 400 changed lines each

## Definition of Done

An issue is closed when:

- [ ] Spec in `docs/specs/` exists and its tasks are ticked
- [ ] Backend, shared, Android and iOS parts are merged (whatever the story needs)
- [ ] Tests written and green in CI, coverage rules met ([testing.md](testing.md))
- [ ] Accessibility ([checklist](../checklists/accessibility-and-motion.md)) and [security rules](../security/rules.md) followed
- [ ] `contracts/openapi.json` updated if the API changed
- [ ] `status.md` and CHANGELOG updated (separate `docs:` PR is fine)
- [ ] Deployed to the server if backend changed (`npm run deploy:api`)

## Order of work

1. **Vertical slices:** one feature at a time, all layers: backend → shared (KMP) → Android → iOS. Not "all backend first, then all apps". Each slice is usable on its own.
2. **Phase before phase:** Phase 1 (auth, map, courts) is finished before Phase 2 starts.
3. **Unblocking first:** foundations, then auth (everything needs a user), then the rest.
4. Steps per slice: [guides/ai-project-process.md](ai-project-process.md) and [checklists/new-feature.md](../checklists/new-feature.md).

## Branches, commits, PRs

As in [CONTRIBUTING.md](../../CONTRIBUTING.md): short branches (`feat/`, `fix/`, `docs/`, …), Conventional Commits, PRs < 400 lines, squash merge, `main` is protected. Docs/reports go in their own `docs:` PR.

## Documentation for humans and AI

- Every session starts with [team/sitzungen.md](../team/sitzungen.md) and ends with one entry there (rules in `CLAUDE.md`).
- New decision about the repo/build → ADR. Product/design decision → Notion (Design → Decisions) and a line in [team/entscheidungen-log.md](../team/entscheidungen-log.md) if the agents decided it.
- Write so an agent without context can act: concrete paths, issue numbers, commands. No duplicates, link instead.
