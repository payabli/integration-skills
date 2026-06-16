# Payabli integration skills

This repo ships Payabli integration **Agent Skills** in `skills/` — one `skills/<name>/SKILL.md` per skill, each with a `references/` folder.

When working on a Payabli integration, consult the relevant skill **before** writing Payabli API, webhook, or SDK code. Match the task to a skill by its frontmatter `description`. Start a new integration with `payabli-getting-started`, and load `payabli-fundamentals` first — every other skill expects it.

Agents with native Agent Skills support discover these once the skills are in a directory they scan:
- **Claude Code** — installed as a plugin (`.claude-plugin/`).
- **Cursor (≥2.4), Codex CLI, GitHub Copilot, and Gemini CLI** — install with the skills.sh CLI (`npx skills add payabli/integration-skills`), or copy `skills/*` into the agent's skills directory.

If your agent reads repo instructions but hasn't been given the skills in its own skills directory, this file is the pointer: the skills live in `skills/` — go read the relevant one.
