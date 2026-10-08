# Create Feature

Propose a new feature aligned with BallerApp product and architecture.

## Steps

1. Read `.cursor/project/vision.md`, `product.md`, `roadmap.md`, `user_stories.md`, `architecture.md`.
2. Check ADRs in `.cursor/rules/` (especially repository pattern, FastAPI backend).
3. Draft the proposal:

**Feature Name**

**Problem:** What user pain does this solve?

**User Story:** As a … I want … So that …

**Acceptance Criteria:** When … / Users can …

**Technical Design:** Repository + API route (if needed) + Flutter screens. No direct Supabase in widgets.

**Implementation Tasks:** Numbered, small PR-sized steps.

4. Append a new .md file with the name `##-feature-name ` to the folder `.cursor/project/userStories` (a number instead of the "#"  but the number is how much important that feature is for the application)
5. Note any security or design implications (tokens, auth, map/location).
