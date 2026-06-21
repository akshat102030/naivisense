# Project Lessons

Read this file at the start of every Claude Code session. Add an entry after each user correction, then apply the rule to the active task.

## Entry Format

### YYYY-MM-DD - Short title

- **Correction:** What behavior or assumption needed correction.
- **Prevention rule:** A general rule that prevents the same class of mistake.
- **NaiviSense application:** How the rule applies in this repository.

## Lessons

### 2026-06-14 - Verification requires evidence

- **Correction:** Simulated workflow check: completion must not be inferred from files merely existing.
- **Prevention rule:** Do not mark work complete until relevant checks have run and their outcomes are recorded; clearly separate automated evidence from manual checks.
- **NaiviSense application:** Run Flutter checks for mobile changes, backend tests and builds for API changes, and structural validation for Claude configuration changes.
