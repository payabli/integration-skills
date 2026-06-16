# Contributing

How skills in this repo are authored and validated. These conventions are what keep the skill set accurate, consistent, and cheap to maintain.

## Skill structure

One directory per skill under `skills/`, named `payabli-<capability>`:

```
skills/
  payabli-fundamentals/
    SKILL.md            # required
    references/         # optional, loaded on demand
      auth.md
      idempotency.md
```

The `payabli-` prefix is intentional: under a Claude plugin the skill is namespaced (`payabli-integrations:payabli-fundamentals`), but via local clone or other agents there's no namespace, so the name has to be self-identifying.

## SKILL.md frontmatter

Required fields (per the [Agent Skills spec](https://agentskills.io) and `skill-validator`):

```markdown
---
name: payabli-webhooks
description: Use when the developer is writing or modifying a webhook handler for Payabli events — verifying signatures, processing event payloads, configuring event subscriptions, routing events across multiple paypoints, or weighing the webhooks-vs-polling tradeoff. Reads payabli-integration.md on load if present.
---
```

The `description` is the trigger contract — it controls *when* the skill fires. Rules:

- **Describe when to use it**, in capability terms a developer would say ("writing a webhook handler," "adding card payments"), not Payabli product names.
- **Carry boundary cross-references.** When a skill borders another, name it: "Subscriptions live in `payabli-subscriptions`." These pointers are what let an agent reject the wrong skill — they were the deciding factor in trigger-routing validation. A skill without them will misfire.
- Surface skills end with: "Reads `payabli-integration.md` on load if present."

## The cascade pattern

Every skill except `payabli-fundamentals` opens its **body** with:

> If `payabli-fundamentals` is not already loaded, load it now, then continue.

This keeps `payabli-fundamentals`' own trigger narrow (it loads via the cascade, not a broad description) while guaranteeing the foundational context is present before any surface work.

## Procedural is written; factual is linked

This is the maintenance contract — it's what keeps skills from going stale.

- **Procedural knowledge** (the "do X before Y," the decision order, the gotchas) is **hand-written** in the skill. This is the part that's valuable and the part that *should* force human review when it changes.
- **Factual content** (exact field names, endpoint paths, response shapes, error codes) is **never copied in** — link out to the live docs instead: `https://docs.payabli.com/{path}.md` for a page, or a section-level index like `https://docs.payabli.com/developers/llms.txt` for bulk context. The agent fetches on demand, so facts can't drift. The full set of section indexes and AI-access endpoints — including token-saving variants like `/developers/llms-full.txt?excludeSpec=true` and `?lang=` — is catalogued at `https://docs.payabli.com/ai-agents.md`.

If you're tempted to paste a field table, link the `.md` page instead.

## Recommend best practice; stay neutral only on genuine choices

- **Recommend** where there's a technical best practice: the SDK over raw HTTP, idempotent handlers, sound error handling. That expertise is what the skill is for.
- **Enumerate neutrally** where the choice is genuinely the partner's: which products to integrate, embedded component vs. hosted page.
- **Never nudge on Payabli's business interest** (margin, upsell). That's the only thing the "no thumb on the scale" rule guards.

## Validation

Before merging a skill:

1. **Structure:** `skill-validator` (`brew tap agent-ecosystem/tap && brew install skill-validator`) — checks frontmatter, required fields, and spec conformance. Runs in CI on every PR.
2. **Quality self-score:** score against the LLM-judge rubric (Clarity, Actionability, Token Efficiency, Scope Discipline, Directive Precision, Novelty) — target 4+ on each, 3+ on Novelty.
3. **Plugin manifest:** `claude plugin validate .` checks `plugin.json` / `marketplace.json`.

## Versioning

The repo follows [semver](https://semver.org): patches for content refinements, minors for new skills/references, majors for trigger changes or removed skills. During early development the manifest pins no `version`, so each commit is the current version; explicit semver tags begin with the first stable release.

## Maintenance

Links and third-party install instructions drift over time. Two things keep them honest:

- **Monthly link check** — `.github/workflows/link-check.yml` runs `tools/check-doc-links.sh --all` on a schedule and opens an issue if anything has rotted. Run it locally anytime with `bash tools/check-doc-links.sh --all`.
- **Freshness runbook** — `tools/repo-freshness-check.md` is a maintainer runbook (deliberately not a skill) that also re-verifies each agent's install instructions against its current docs.
