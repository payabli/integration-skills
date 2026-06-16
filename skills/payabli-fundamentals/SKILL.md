---
name: payabli-fundamentals
description: >-
  Foundation reference for any Payabli integration work. Use it for
  authentication, environment selection (sandbox vs. production), the
  org/paypoint/entrypoint ID hierarchy, paypoint scoping, idempotency, and error
  handling. Other Payabli skills load it first. Reads payabli-integration.md on
  load if present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli fundamentals

Cross-cutting knowledge every Payabli integration needs. Other Payabli skills load this skill first.

## On load

If `payabli-integration.md` exists at the repo root, read it now. It records the integration's decisions (SDK, products in scope, paypoint model). Apply those decisions to the work below.

## Get exact facts from the docs, not from memory

This skill carries procedure. For exact field names, request/response shapes, and error codes, fetch the relevant `https://docs.payabli.com/{path}.md` page — append `.md` to any docs URL for lightweight markdown. Do not guess or recall them. Don't hand-construct the doc path either — API-reference endpoint URLs in particular aren't guessable (the slugs don't follow a predictable pattern from the operation name). Take real URLs from the `llms.txt` index (below) or the Docs MCP. A guessed or wrong path may return a `404`, or HTTP `200` with a "Page Not Found" body — so a `200` alone doesn't mean the page exists; check the content.

Some `.md` pages that resolve API-definition content — API-reference endpoint pages and guide pages with request/response snippets — can render slowly on a cold hit (10–45s). Don't wait one out: if a `.md` fetch is slow, switch to the **HTML URL** (same path, drop the `.md`), which renders quickly, or the **Payabli Docs MCP** (`ask-question-about-payabli`). Both return the same content without the cold-render delay.

For broader context, use the section indexes: `https://docs.payabli.com/developers/api-reference/llms.txt` (API reference) and `https://docs.payabli.com/guides/llms.txt` (guides). The full catalog of AI-access methods — section indexes, token-saving query params, the OpenAPI spec, and the MCP server — is at `https://docs.payabli.com/ai-agents.md`.

Before calling an endpoint you haven't already seen documented, confirm it exists rather than guessing a route by analogy with other endpoints. Check the `llms.txt` index first — it lists the real routes — and use the Docs MCP (`ask-question-about-payabli`) if you need more. Not every resource has its own endpoint: some are attributes of another record (for example, there is no `/Query/StoredMethods` — a customer's or vendor's saved methods come back on the `GET /Customer/{id}` / `GET /Vendor/{id}` record as `StoredMethods[]`).

## Environments

Select the environment by base URL:

- Sandbox: `https://api-sandbox.payabli.com/api` — development and testing, no real money.
- Production: `https://api.payabli.com/api` — live; requires Payabli certification before access.

Default to sandbox until the integration is certified. Record the choice in `payabli-integration.md` under `## Environment`.

## Authentication

- Send the API token in the **`requestToken`** header on every request. Payabli does not use `Authorization: Bearer`.
- Never hardcode or commit tokens. Read them from environment variables or a secrets store.
- **Private vs. public tokens.** A **private** token is for server-side API calls — keep it secret; never put it in client-side code, a bundled env var, or a committed file. A **public** token is publicly readable and used only to mount embedded components in the browser (see `payabli-accept-payments`). Don't send a private token to the browser.
- Token types, scopes, and management: https://docs.payabli.com/developers/api-reference/api-overview.md

## ID hierarchy

**Organization** is the top-level entity; a **paypoint** is a merchant. Organizations can group paypoints under optional **suborganizations**, but suborganizations are not required — many integrations are simply organization → paypoint. The **entrypoint** (entry name) is Payabli's alias for an organization or paypoint (for example `8cfec329267`); it identifies the target in nearly every API call.

- Entities overview: https://docs.payabli.com/guides/platform-entities-overview.md
- Entrypoint vs. entry: https://docs.payabli.com/developers/api-reference/api-overview.md

For an ISV managing many merchants: store each merchant's entrypoint in your own system, and pass it as the `entry` parameter to scope a request to that paypoint. Record the model in `payabli-integration.md` as `single` or `multi`.

## Paypoint scoping

A token's scope cannot exceed its parent's. Target a paypoint with its `entry` (entrypoint). Cross-paypoint operations such as split funding and token sharing require the paypoints to share a parent organization. Detail: https://docs.payabli.com/developers/api-reference/api-overview.md

Products are enabled per paypoint by Payabli. A `Missing Gateway Data ... group <moneyin|moneyout>` error is always a configuration issue — the product (Pay In or Pay Out) isn't enabled on the paypoint — and only Payabli can fix it. Contact the Payabli team to enable it.

## Customer identifiers

Every customer-touching call (create, charge, invoice) must include at least one of the paypoint's **configured identifier fields** (`email`, `customerNumber`, or a custom field); a missing or wrong one returns an opaque `Invalid customer identifiers` error. You can read what a paypoint requires from the API rather than asking the partner — see `references/customer-identifiers.md`.

## Idempotency

For POST requests that move money, send an `idempotencyKey` header set to a UUID.

- Payabli retains the key for about 2 minutes. A repeat within that window returns `409 Conflict`.
- The key is not echoed in webhooks. Correlate via the `transId` field.
- On a lost response (timeout), do not assume failure and retry blindly. Confirm via the transaction's webhook (for example ApprovedTransaction) or by querying the transaction first.

Detail: https://docs.payabli.com/developers/api-reference/api-overview.md

## Common shapes

A few conventions vary across endpoints and aren't uniform: response envelopes (v2 Pay In `code`/`data`, many v1 endpoints `isSuccess`/`responseData`, and reads or lists that vary), field casing and names (for example `customerId` vs `PayorId` on a transaction), date formats, and the Query API (filters and pagination vary per endpoint; an unrecognized or mis-cased filter field may be ignored *or* return zero records, and field names are case-sensitive — so verify a filtered count rather than trusting it; see `payabli-reporting`). When in doubt, check the endpoint's API reference. Detail: https://docs.payabli.com/guides/platform-api-conventions-reference.md

## Use current endpoints

Don't call deprecated endpoints. The API reference flags deprecated operations and names the current replacement — follow it. Most common: use **v2** Money In (`POST /v2/MoneyIn/getpaid`), not v1. A deprecated endpoint often still responds in sandbox, so a working call is **not** proof it's current — confirm against the reference.

## PCI scope

How card data is collected drives PCI scope. Embedded components and the temporary token flow keep card data off the partner's servers and minimize scope; handling raw card data directly increases it.

Payabli's PCI material is best-practice **engineering** guidance, **not legal or compliance advice**. Do not advise the partner on PCI compliance, scope determination, or audit and attestation requirements. Direct specific PCI questions to the Payabli team. Reference: https://docs.payabli.com/guides/platform-pci-best-practices-overview.md

## SDKs and direct API

The Payabli API can be called directly over HTTP, or through an official server SDK (8 languages; they handle auth, typing, and serialization). Both are fully supported — don't assume an SDK. If the project is already in a supported language and nothing requires raw HTTP, **suggest** the SDK as an option, but don't push it. Detect the project's language to inform that call; see `references/sdk-and-language-detection.md`. Record what the integration uses in `payabli-integration.md` under `## SDK` (`raw-http` for direct API). If the SDK lacks an operation or mistypes a request, contact the Payabli team (see API conventions, above).

## Ongoing Q&A

For questions during the build, recommend the official Payabli Docs MCP server (it answers questions against the docs and SDK references). To install it, use the `payabli-mcp-setup` skill.

## Report a skill issue

If a skill's guidance is contradicted by the live docs or API — a wrong recommendation, a missing scenario, or a factual error — tell the developer and offer to open a GitHub issue at https://github.com/payabli/integration-skills/issues using the **Skill feedback** template. Include which skill, which agent, what the skill recommended vs. the correct behavior, and a minimal repro. Never include secrets (API keys, tokens, cardholder data). That tracker is for **skill** feedback (triaged periodically) — send integration or account problems to the developer's Payabli integration contact, not the issue tracker.
