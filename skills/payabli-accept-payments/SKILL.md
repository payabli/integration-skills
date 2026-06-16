---
name: payabli-accept-payments
description: >-
  Use when writing code that accepts payments through Payabli: charging cards or
  ACH, integrating embedded payment components or a hosted payment page, handling
  Apple Pay or Google Pay, or processing voids and refunds. Boundaries —
  subscriptions: payabli-subscriptions; invoices and payment links:
  payabli-invoices; disputes and refund-failure recovery: payabli-disputes.
  Reads payabli-integration.md on load if present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli accept payments (Pay In)

Core Pay In: take a payment, choose the integration surface, and handle the transaction through its lifecycle.

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## On load

If `payabli-integration.md` exists at the repo root, read it. Honor its `## SDK` value for code examples and its `## Pay In` scope.

## Step 1 — Choose the integration approach

Three ways to collect a payment. Recommend embedded components as the default (lowest PCI scope); the others are valid when the partner needs them. Enumerate — don't decide for them.

- **Embedded components (recommended)** — payment UI inside the partner's app; Payabli handles card data, keeping PCI scope low. They can be extended with the **temporary token flow** for full API control over the charge while still keeping card data off the server (see `payabli-tokenization`). https://docs.payabli.com/guides/pay-in-components-overview.md
- **Hosted payment page** — no-code, Payabli-hosted; redirects off-site, less customizable. Do not embed it in an iframe. https://docs.payabli.com/guides/pay-in-payment-page-overview.md
- **Direct API** — the partner integrates the payment API directly and handles card data themselves, which raises their PCI responsibility. Follow Payabli's PCI best practices. https://docs.payabli.com/guides/platform-pci-best-practices-overview.md

> **PCI is not legal advice.** Payabli's PCI materials are engineering best practices, not legal or compliance advice. Do not advise the partner on PCI compliance, scope determination, or audits. Direct specific PCI questions to the Payabli team.

If using embedded components, pick the component:

| Component | Use for | PayabliExec actions |
| --- | --- | --- |
| EmbeddedMethod UI | charge or save a method (most flexible) | `pay`, `method`, `reinit` |
| ExpressCheckout UI | digital wallets (Apple Pay, Google Pay) | `pay`, `method`, `reinit` |

Component guides: https://docs.payabli.com/guides/pay-in-components-embeddedmethod-ui.md · https://docs.payabli.com/guides/pay-in-components-express-checkout.md

**Components authenticate with a public token**, passed in the component config — *not* your private (server-side) API token. Public tokens are publicly readable and safe to ship to the browser; never put a private token in client-side code. (Creator components require a public token with domain restrictions.) https://docs.payabli.com/developers/api-reference/api-overview.md

**Framework/bundler gotcha:** `PayabliComponent` is a global symbol — instantiate it as `new PayabliComponent({...})`, not `window.PayabliComponent`. If the constructor isn't found, the component shows a misleading "couldn't load / check network and token" even though the script loaded — check the global access first. When server-side rendering, use a stable component container identifier. See https://docs.payabli.com/guides/pay-in-developer-components-frameworks.md

PayMethod UI (a save-method-only lightbox) is also available, but it is less flexible than EmbeddedMethod UI and is not a default choice. https://docs.payabli.com/guides/pay-in-components-paymethod-ui.md

## Step 2 — Make the charge

A one-time **sale** authorizes and captures in one call: `POST /v2/MoneyIn/getpaid`. Use the v2 endpoints — v1 is being deprecated. Send an `idempotencyKey` on this call (see `payabli-fundamentals`). https://docs.payabli.com/guides/pay-in-developer-transactions-create.md

If a sandbox charge returns `E9999` ("Unexpected error"), it usually means the card isn't a valid Payabli test card — not an outage. Retry with a canonical test card from `payabli-testing`.

Separate **authorize** then **capture** when you must confirm before taking funds (for example, verifying availability or finalizing the amount). https://docs.payabli.com/guides/pay-in-developer-transactions-auth-capture.md

## Step 3 — Know the lifecycle

A transaction moves Authorized → Captured → batch close → in transit → funded, and is largely final once its batch closes. This drives the reversal choice below. https://docs.payabli.com/guides/pay-in-transactions-lifecycle-overview.md

When you query a transaction, its state comes back as a numeric `TransStatus` (for example, `1` = approved/captured, `11` = authorized, `5` = voided/canceled). Map the full set — including declines and rejections — with the Pay In status reference. https://docs.payabli.com/guides/pay-in-status-reference.md

## Step 4 — Reverse a payment: void vs. refund

Check settlement status first:

- **Void** an unsettled transaction (before batch close) — avoids interchange fees; funds never leave the customer.
- **Refund** a settled transaction (after batch close) — partial refunds are allowed.

https://docs.payabli.com/guides/pay-in-transactions-void-vs-refund-decision.md

A refund that *fails* (errors or later reverses) is recovery work — use `payabli-disputes`, not this skill.

To *test* a refund in sandbox you need a settled transaction, and reaching settled/funded requires a Payabli-side funding trigger (see `payabli-testing`).

## ACH

Use the same `/v2/MoneyIn/getpaid` flow with an ACH method. Unlike cards, ACH settles over multiple days and can return after the fact, so confirm final status before treating a payment as good. Return codes: https://docs.payabli.com/guides/platform-ach-return-codes-reference.md · cycle: https://docs.payabli.com/guides/pay-in-ach-cycle-overview.md

## Digital wallets

Apple Pay and Google Pay run through ExpressCheckout UI and require domain registration before use. https://docs.payabli.com/guides/pay-in-wallets-apple-pay-overview.md · https://docs.payabli.com/guides/pay-in-wallets-google-pay-overview.md

## Customers

Customers are foundational to Pay In, not only to tokenization. Create one with `POST /Customer/single/{entry}`; each paypoint keeps its own customer list (customers are not shared across paypoints). You can't charge without a customer, so this is usually the first call. https://docs.payabli.com/guides/pay-ops-developer-customers-manage.md

When charging through an embedded component (`payabliExec('pay')`), pass the existing `customerId` in `customerData` so the charge links to that customer instead of creating a new one.

**Body-shape gotcha:** the create-customer body is **flat** — `firstname`, `email`, and the rest sit at the top level, *not* wrapped in `customerData` the way the transaction endpoints nest them. Include an `identifierFields` array plus at least one of the paypoint's configured identifiers (see `payabli-fundamentals` → Customer identifiers).

To save a payment method for reuse, use `payabli-tokenization`.

## Other surfaces

Card-present devices, remote deposit capture, IVR, Level 2/3 data, and split funding are covered in `references/other-surfaces.md`.

## Boundaries

- Recurring billing / autopay → `payabli-subscriptions`
- Invoices and customer payment links → `payabli-invoices`
- Chargebacks, disputes, and refund-failure recovery → `payabli-disputes`
