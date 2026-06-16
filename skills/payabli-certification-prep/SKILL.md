---
name: payabli-certification-prep
description: >-
  Use when a partner wants to rehearse the Payabli certification test scenarios
  in sandbox before their certification call — running the checks they can
  self-serve and confirming expected results. This is prep for the call, not
  self-certification (certification happens with a Payabli SE). Reads
  payabli-integration.md on load if present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli certification prep

Rehearse the certification test scenarios in sandbox so the partner walks into their Payabli certification call confident. **This preps for the call — it does not certify; certification happens with a Payabli SE.**

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## On load

If `payabli-integration.md` exists at the repo root, read it and run only the recipes for the products in scope (`## Pay In`, `## Pay Out`, `## Webhooks`, `## Tokenization`). Don't walk a partner through Pay Out cases if they only integrated Pay In.

## How to use

1. Pick the areas in scope (from the plan, or ask).
2. Load the matching reference(s) and run each recipe in **sandbox**, recording the reference ID and result.
3. Most recipes are self-serve. A few need a Payabli-side trigger (a settled/funded state, or certain webhook events) — those are marked. Note them and raise them on the cert call rather than getting blocked.
4. When the self-serve set passes, the partner is ready for the certification call.

## Recipes by area

- Pay In — cards, ACH, auth/capture, void/refund: `references/pay-in.md`
- Stored methods / tokenization: `references/tokenization.md`
- Subscriptions: `references/subscriptions.md`
- Webhooks: `references/webhooks.md`
- Pay Out — payouts, vendors, bills: `references/pay-out.md`

## Results scorecard

Record each recipe's outcome in a table like this and bring it to the cert call:

| Area | Recipe | Expected | Actual (code · ref ID) | Pass? |
|---|---|---|---|---|
| Pay In | Sale | `A0000` approved |  |  |
| Pay In | Decline | `D0100` decline |  |  |
| Pay In | Void (pre-settlement) | `A0003` canceled |  |  |
| Pay In | Over-amount / early refund | `E7002` rejected |  |  |
| Tokenization | Token not found | `7007` |  |  |
| Webhooks | ApprovedPayment delivery | HTTP 200 ack |  |  |

Add a row per recipe you run. For anything that needs a Payabli-side trigger, mark it "raise on call" instead of pass/fail.

## What needs a Payabli-side trigger (flag, don't get stuck)

Successful refunds (need a settled transaction → funding), cancel-after-settled, and chargeback/return webhook events require Payabli to trigger them in sandbox. Subscription *execution* is self-serve but time-based — schedule near-term and wait. See `payabli-testing`.

## Boundary

Sandbox mechanics (test cards, environments, what needs a trigger) → `payabli-testing`. This skill is the certification rehearsal specifically.
