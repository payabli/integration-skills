# Payabli Integration Agent Skills

> **Status: beta.** The skills are live and growing — we're adding coverage and refining as partners put them to work, so expect changes.

[Agent Skills](https://agentskills.io) that [Payabli](https://payabli.com) partners install in their coding agent to integrate Payabli — from building the integration through getting ready for your certification call — without hands-on integration support. They work in any agent that supports the open Agent Skills standard, including Claude Code, Cursor, Codex, GitHub Copilot, and Gemini CLI.

Skills ship Payabli-specific **procedural** knowledge directly into your coding agent: the order of operations, the decisions that matter, and the patterns that keep a payments integration correct. They load just-in-time, when your agent is about to write Payabli-touching code.

Skills are complementary to the official **Payabli Docs MCP server**: the MCP answers questions (Q&A), skills sequence the work. Both read from the same source of truth — `docs.payabli.com` — so they converge on the same answers.

> **Use AI responsibly.** These skills are crafted by the Payabli team, and they steer an AI coding agent inside your environment. AI output isn't perfect — review and verify everything your agent generates against the official docs (`docs.payabli.com`) and your sandbox before you ship it, and reach out to your Payabli integration contact if something looks wrong or you need confirmation. Never paste or save secrets (API keys, tokens, cardholder data) into your agent or commit them to your repo; use sandbox credentials and environment variables.

**Jump to:** [The skill set](#the-skill-set) · [What you'll need](#what-youll-need) · [Install](#install) · [Usage](#usage) · [Repo structure](#repo-structure) · [Resources](#resources) · [Contributing](#contributing)

## The skill set

Organized by what you're building, not by Payabli's product taxonomy.

| Skill | What it's for |
| --- | --- |
| `payabli-getting-started` | Design/onboarding entry point; maps your capability goal to the Payabli pieces and writes an integration plan |
| `payabli-fundamentals` | Auth, IDs, paypoint scoping, idempotency, error handling — loaded by every other skill |
| `payabli-accept-payments` | Pay In core: cards, ACH, wallets, embedded components, hosted pages |
| `payabli-customers` | Customer records: create, read, list/search, update, delete, transaction history |
| `payabli-subscriptions` | Recurring billing, autopay, dunning |
| `payabli-invoices` | Invoices and customer-facing payment links |
| `payabli-disputes` | Chargebacks, evidence, refund failures |
| `payabli-send-payments` | Pay Out core: payouts, reissue |
| `payabli-vendors` | Vendor records: create, read, list/search, update, delete, payment history |
| `payabli-bills` | AP automation: bill capture, OCR, approvals |
| `payabli-webhooks` | Webhook handling and event processing |
| `payabli-tokenization` | Saved payment methods (Pay In and Pay Out) |
| `payabli-reporting` | Query API for reports and list/detail data UIs, reconciliation, settlement tracking |
| `payabli-testing` | Sandbox usage, test data, and event simulation |
| `payabli-certification-prep` | Rehearse the certification test scenarios in sandbox before the cert call |
| `payabli-mcp-setup` | Installs the official Payabli Docs MCP server |

Every skill above is live. New skills start with `payabli-getting-started`, which loads `payabli-fundamentals` and pulls in the rest as the work calls for them.

> We're adding skills over time, so some Payabli capabilities don't have one yet — for example **merchant boarding** (onboarding merchants).

## What you'll need

These skills are for building **on Payabli**, so you'll need a Payabli account with API access — that's where your sandbox credentials come from. Not a Payabli customer yet? [Request a demo](https://payabli.com/demo/?utm_source=github&utm_medium=referral&utm_campaign=integration-skills&utm_content=readme).

The skills steer your agent; you supply the credentials to test while building. To build and test against sandbox you'll need an **organization ID** and at least one **entrypoint ID** (a paypoint), plus a **private** API token (and a separate **public** token, if you mount embedded components in the browser). Read these from environment variables; never hardcode or commit the private token. A typical local `.env`:

```bash
# Payabli sandbox credentials. Copy into your app's local env file (e.g. .env.local),
# keep it gitignored, and never commit real values.
PAYABLI_BASE_URL=https://api-sandbox.payabli.com/api
PAYABLI_API_TOKEN=      # PRIVATE token — server-side only; never expose to the browser or commit
PAYABLI_ENTRYPOINT=     # an entrypoint (paypoint) to target; needed by nearly every call
PAYABLI_ORGID=          # organization ID — for org-scoped calls (e.g. notifications, reporting)

# Only if you mount embedded payment components in a browser:
PAYABLI_PUBLIC_TOKEN=   # PUBLIC token — publicly readable, safe to expose client-side

# Optional — only if you're handling webhooks. Shared secret you check on inbound
# webhooks and set as the subscription's Authorization header.
PAYABLI_WEBHOOK_SECRET=
```

`payabli-fundamentals` explains the org/paypoint/entrypoint hierarchy and where these IDs come from; `payabli-testing` covers sandbox test data.

## Install

`skills/` is the canonical source (one `skills/<name>/SKILL.md` each). They work in any agent that supports the open Agent Skills standard, including Claude Code, Cursor, Codex, GitHub Copilot, and Gemini CLI.

**Claude Code** — install the plugin from Payabli's self-hosted marketplace:

```bash
/plugin marketplace add payabli/integration-skills
/plugin install payabli-integrations@payabli
```

Pair the skills with the **Payabli Docs MCP** (Q&A against the docs and SDK references) — install it with the `payabli-mcp-setup` skill.

**skills.sh CLI** — a cross-agent install (Cursor, Codex, and others):

```bash
npx skills add payabli/integration-skills                                   # all skills
npx skills add payabli/integration-skills --skill payabli-accept-payments   # one skill
npx skills add payabli/integration-skills --list                            # list what's available
```

**GitHub Copilot** — Copilot reads Agent Skills natively (Copilot CLI, the VS Code agent, cloud agent, and code review). Copy the folders from `skills/` into a directory it scans — `.github/skills`, `.claude/skills`, or `.agents/skills` in your repo, or `~/.copilot/skills` for personal use. See [Adding agent skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills).

**Gemini CLI** — also reads Agent Skills natively. Copy the folders from `skills/` into `.gemini/skills/` (project) or `~/.gemini/skills/` (personal). See [Agent Skills](https://geminicli.com/docs/cli/skills/).

**Manual (any agent)** — clone the repo and symlink or copy `skills/*` into your agent's skills directory (on Windows, copy rather than symlink). Many agents also read the shared `.agents/skills/` convention.

> Cursor needs ≥2.4 for native skills.

## Usage

You don't invoke skills by name — they load automatically when your agent is about to write Payabli code. Just describe what you're building:

- "Add a Payabli checkout to my Next.js app so customers can pay by card."
- "Charge a saved payment method for this customer."
- "Set up a recurring monthly subscription."
- "Send an invoice with a payment link by email."
- "Pay this vendor $500 by ACH."
- "Build a transactions report with status filters."
- "Walk me through the Payabli certification scenarios so I'm ready for my cert call."

**Not sure where to start?** Point your agent at your project:

> "I want to add Payabli payments to this app — look at my stack and tell me which Payabli pieces I need and how to wire them up."

That pulls in `payabli-getting-started`, which interviews you, maps your goal to the right components, and writes a `payabli-integration.md` plan the other skills follow.

## Repo structure

```
.claude-plugin/   Claude Code plugin + self-hosted marketplace manifests
.github/          Issue templates, CI workflows, and Copilot repo instructions
AGENTS.md         Repo instructions that point agents at skills/
SECURITY.md       How to report a security concern
skills/           The skills — one directory per skill (SKILL.md + references/)
tools/            Maintenance scripts + runbooks (link checker, freshness check)
```

## Resources

- **Docs:** https://docs.payabli.com
- **Example apps:** https://github.com/payabli/examples — a full suite of runnable integration examples
- **Payabli Docs MCP** — Q&A against the docs and SDK references; install via the `payabli-mcp-setup` skill, or see https://docs.payabli.com/ai-agents
- **API reference:** https://docs.payabli.com/developers/api-reference/api-overview
- **Support:** contact your Payabli integration contact.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for how skills are authored, the procedural-vs-factual rule, the cascade pattern, and validation.

Found a wrong recommendation, a missing scenario, or a factual error? [Open an issue](https://github.com/payabli/integration-skills/issues).

## License

[MIT](./LICENSE)
