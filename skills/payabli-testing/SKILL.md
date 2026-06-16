---
name: payabli-testing
description: >-
  Use when testing a Payabli integration — sandbox usage, test cards and bank
  data, simulating events, or preparing a sandbox-to-production cutover. Reads
  payabli-integration.md on load if present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli testing

Exercise an integration in sandbox before going live.

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## On load

If `payabli-integration.md` exists at the repo root, read it; honor its `## Environment` value (default `sandbox` until certified).

## Sandbox

Sandbox uses its own base URL, `https://api-sandbox.payabli.com/api`. Partners receive a sandbox account at integration kickoff. Sandbox transactions auto-settle daily (default 9 PM UTC; adjustable by your Payabli contact). https://docs.payabli.com/developers/platform-developer-testing-guide.md

## Test cards and bank data

Use Payabli's published test cards and test bank accounts — including cards that force a decline — rather than inventing values. https://docs.payabli.com/guides/test-accounts-reference.md

## What needs Payabli to trigger in sandbox

Most of sandbox is self-serve, but a few things **can't be triggered on your own** — you have to ask your Payabli contact to fire them. This trips up integrators constantly, so plan for it: build and verify everything self-serve first, then batch the Payabli-side triggers with your contact rather than getting blocked mid-test.

- **Some webhook events** — payment-event webhooks (for example `ApprovedPayment`) fire when you run the transaction, but chargebacks, ACH returns, and similar events require Payabli to trigger them.
- **Some transaction-status transitions** — a transaction won't always advance through its lifecycle on its own.
- **Funding triggers** — advancing to settled/funded. This gates anything settlement-dependent, most commonly **refunds** (which need a settled transaction).

https://docs.payabli.com/developers/platform-developer-testing-guide.md

## Keep responses small when you run calls

When you run calls and read the responses back — exercising a flow, debugging, or verifying a result — query narrowly: request the specific record, and filter or paginate list endpoints instead of pulling whole collections. Payabli responses are large and vary per endpoint, so a broad query returns far more than you need and floods context. This only matters when an agent is executing and interpreting output; integration code you write for the app to run at runtime isn't affected.

## Prepare for production cutover

Production access requires Payabli certification and underwriting — this is **not** self-serve; it's coordinated with the Payabli team. Prepare by exercising every flow your integration uses in sandbox first, so the review goes smoothly.

## Boundary

Configuring and handling webhook events → `payabli-webhooks`.
