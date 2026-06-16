# Repo freshness check (maintainer runbook)

A monthly maintenance pass for this repo. It's deliberately a plain runbook, not a `SKILL.md`, so it isn't treated like a skill.

Goal: catch drift before partners do. Two things rot over time — outbound links, and the third-party install instructions we mirror. Each coding agent changes its skill directories, CLI flags, and version gates on its own schedule, so what was accurate at launch quietly goes stale.

## How to run it

Work through the steps below, then report a single checklist. Mark each item:

- **OK** — still accurate.
- **CHANGED** — give the old value, the new value, and the source URL.
- **BROKEN** — link no longer resolves.

Don't edit files silently. After the checklist, if anything is CHANGED or BROKEN, offer to open a PR with the fixes.

### 1. Outbound links

Run the repo's link checker in full-scan mode and report anything that fails:

```bash
bash tools/check-doc-links.sh --all
```

This checks the `docs.payabli.com` links under `skills/` plus the outbound links in `README.md`, `AGENTS.md`, and the other top-level docs — external hosts included. Treat any non-resolving link as **BROKEN**. (A monthly GitHub Action runs the same command and opens an issue on failure; this runbook is the on-demand version, plus the install-instruction review below.)

### 2. Agent install instructions

For each agent below, fetch its current official docs and confirm the claim we make still holds — scan directories, CLI command and flags, and version gates. Capture the new value and the doc URL wherever a claim has changed.

| What we claim | Where we say it | Check against |
| --- | --- | --- |
| Claude Code plugin install (`/plugin marketplace add`, `/plugin install`) | README → Install | https://docs.claude.com/en/docs/claude-code/plugins |
| skills.sh `npx skills add` syntax + flags (`--skill`, `--list`) | README → Install | https://skills.sh |
| GitHub Copilot reads skills natively from `.github/skills`, `.claude/skills`, `.agents/skills`, `~/.copilot/skills` | README → Install | https://docs.github.com/en/copilot/concepts/agents/about-agent-skills |
| Gemini CLI reads skills from `.gemini/skills/` and `~/.gemini/skills/` | README → Install | https://geminicli.com/docs/cli/skills/ |
| Cursor native skills require ≥ 2.4 | README → Install | https://docs.cursor.com/agent/skills |

If an agent we don't list yet has added Agent Skills support, flag it as a possible addition rather than editing silently.

### 3. Pinned references

- The CI workflow pins the skill-validator version (`.github/workflows/skill-validator.yml`). Check whether a newer release exists and whether the current pin still passes.

## Notes

- This reads public docs only — no credentials or secrets are involved.
- Keep any fixes factual and the copy calm.
