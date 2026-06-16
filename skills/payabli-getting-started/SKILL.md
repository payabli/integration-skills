---
name: payabli-getting-started
description: >-
  Use at the start of a Payabli integration, when a developer wants to add
  payments to an existing app (accept payments, save payment methods,
  subscriptions, invoices, payouts, or bill pay). Interviews for the use-case
  shape, maps it to the right Payabli components and paypoint architecture,
  detects the SDK, and offers to write a payabli-integration.md plan that the
  other Payabli skills read.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli getting started

The entry point for adding a Payabli-powered capability to an existing application. Translate the developer's stated goal into concrete Payabli pieces, confirm the architecture, and write an optional `payabli-integration.md` plan that downstream skills read.

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## Step 1 — Listen

Read the developer's stated capability goal as given ("add card payments," "pay our vendors," "add bill OCR"). Do not recommend a product. Map what they said to Payabli pieces.

## Step 2 — Map the capability to components

Match the goal to the rows below. Fetch the linked `.md` page for depth, and hand off to the named skill when the developer starts building that piece.

| Capability | Payabli pieces | Usually also | Depth |
| --- | --- | --- | --- |
| Accept card or ACH payments | Pay In — embedded components or hosted page | webhooks; tokenization if saving methods | `payabli-accept-payments` · https://docs.payabli.com/guides/pay-in-overview.md |
| Save payment methods for reuse | Tokenization (customer-scoped) | Pay In | `payabli-tokenization` · https://docs.payabli.com/guides/platform-tokenization-overview.md |
| Recurring billing / subscriptions | Subscription API | tokenization, webhooks | `payabli-subscriptions` · https://docs.payabli.com/guides/pay-in-developer-subscriptions-manage.md |
| Send invoices / payment links | Invoices and payment links | webhooks | `payabli-invoices` · https://docs.payabli.com/guides/pay-in-developer-invoices-manage.md |
| Embedded checkout | Embedded components vs. hosted page (see Step 3) | tokenization | `payabli-accept-payments` · https://docs.payabli.com/guides/pay-in-components-overview.md |
| Pay vendors / payouts | Pay Out (`/MoneyOut`) | vendors, webhooks | `payabli-send-payments` · https://docs.payabli.com/guides/pay-out-overview.md |
| Automate bill pay / AP (incl. bill OCR) | Bills — bill capture (manual entry or OCR) and approval workflows | Pay Out to pay them | `payabli-bills` · https://docs.payabli.com/guides/pay-out-developer-bills-manage.md |
| Real-time status updates | Webhooks (weigh against polling) | — | `payabli-webhooks` · https://docs.payabli.com/guides/pay-ops-notifications-webhooks-vs-polling.md |
| Reports / reconciliation | Pay Ops reporting | — | `payabli-reporting` · https://docs.payabli.com/guides/pay-ops-overview.md |

**Not yet covered:** API merchant boarding (creating and submitting paypoint applications) is coming in a future release. If the partner's goal is onboarding merchants, tell them it's not yet available as a skill and route them to their Payabli contact.

## Step 3 — Recommend best practice; stay neutral on genuine choices

- **Recommend** where there is a technical best practice: idempotency for money-moving calls, and embedded components as the default Pay In surface (lowest PCI scope).
- **Enumerate neutrally** where the choice is genuinely the partner's: which products to integrate, and how to collect payments — embedded components (recommended, in-app, Payabli handles card data; can be extended with the temporary token flow for API control), a hosted payment page (no-code, redirects off-site), or direct API where the partner handles card data (raising their PCI responsibility). PCI guidance is engineering best practice, not legal advice — point them at it and send specific PCI scope questions to the Payabli team. See https://docs.payabli.com/guides/pay-in-components-overview.md, https://docs.payabli.com/guides/pay-in-payment-page-overview.md, and https://docs.payabli.com/guides/platform-pci-best-practices-overview.md.
- **Never** nudge toward a choice on Payabli's business interest (margin, upsell).

## Step 4 — If payouts are in scope, ask the right decision

The partner's decision is **managed vs. on-demand payables** — ask that. The payment **method** (vCard, ACH, check) is the **vendor's**, set on the recipient side; under managed payables, Payabli's team handles vendor outreach (vCard → ACH → check). Do not ask the partner to pick a method, and do not lead with one. See https://docs.payabli.com/guides/pay-out-managed-payables-overview.md.

## Step 5 — Infer the paypoint model, then confirm

Listen for cues, propose the model, and confirm — do not ask cold.

- "my customers," "the merchants we serve," "each location" → **multi** (ISV managing many paypoints).
- One business taking its own payments → **single**.

Entities reference: https://docs.payabli.com/guides/platform-entities-overview.md

## Step 6 — Detect the language; suggest the SDK if it fits

Detect the project's language from its manifest files. Direct API and the SDKs are both fully supported — don't assume an SDK. If the project is in a supported language and nothing requires raw HTTP, suggest the matching SDK as an option (it handles auth, typing, and serialization); don't push it. Use the mapping in `payabli-fundamentals` → `references/sdk-and-language-detection.md`. Record what the integration uses in the plan under `## SDK` (`raw-http` for direct API).

## Step 7 — Offer the plan artifact

Offer to write `payabli-integration.md` at the repo root, capturing the decisions above. Use the format and controlled vocabulary in `references/integration-plan-template.md`. Downstream Payabli skills read this file on load for architecture-aware guidance.

If `payabli-integration.md` already exists, ask whether to update it or archive it (rename to `payabli-integration.<date>.md`) and start fresh.

## Step 8 — Recommend the Docs MCP

Recommend installing the official Payabli Docs MCP server for ongoing Q&A during the build. To install it, point the developer to the `payabli-mcp-setup` skill.
