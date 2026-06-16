---
name: payabli-subscriptions
description: >-
  Use when building recurring billing on Payabli — subscriptions, autopay,
  scheduled charges, retry/dunning logic, or moving one-time charges to
  recurring. Covers the Subscription API, CIT/MIT indicators, and lapse handling.
  One-time charges live in payabli-accept-payments. Reads payabli-integration.md
  on load if present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli subscriptions (recurring billing)

Set up and manage recurring charges (autopays).

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## On load

If `payabli-integration.md` exists at the repo root, read it; honor its `## SDK` value.

## Create and manage a subscription

`POST /Subscription/add` creates an autopay; update and delete with `PUT`/`DELETE /Subscription/{subId}`. A subscription always links to a customer (pass `customerId`), and Payabli tokenizes the method automatically. Scheduled autopays run roughly 2:30–3:30 AM ET; to test the run end to end, use valid schedule data (a bad schedule is rejected) and schedule a near-term time, then wait — no Payabli-side trigger is needed. https://docs.payabli.com/guides/pay-in-developer-subscriptions-manage.md

**Schedule:** in `scheduleDetails`, set `frequency` and an `endDate`. `frequency` is one of `onetime`, `weekly`, `every2weeks`, `monthly`, `every3months`, `every6months`, `annually`, or the month-anchored `firstofmonth` / `fifteenthofmonth` / `endofmonth`. For an open-ended autopay — the common case — set `endDate: "untilcancelled"`; omitting `endDate` fails with `Invalid Schedule data`.

**Read and list:** read one with `GET /Subscription/{subId}`; list with the Query API (`GET /Query/subscriptions/{entry}`). A customer's subscriptions are also embedded in `GET /Customer/{customerId}` as `Subscriptions[]`. Render state from the integer `SubStatus` — see the [subscription status reference](https://docs.payabli.com/guides/pay-in-status-reference#subscription-status).

To put a digital wallet (Apple Pay, Google Pay) on a subscription, tokenize it through the **ExpressCheckout UI** first — wallets are tokenized via ExpressCheckout, not the standard stored-method flow. https://docs.payabli.com/guides/pay-in-components-express-checkout.md

## Set CIT/MIT indicators

Recurring charges are merchant-initiated. Send the `initiator` field (`payor` = cardholder-initiated, `merchant` = merchant-initiated) and `storedMethodUsageType` (for example `subscription`). Wrong indicators cause declines, fee miscalculation, and chargeback-liability shifts; if omitted, Payabli defaults to `merchant` + `unscheduled`, which may not match intent. https://docs.payabli.com/guides/pay-in-transactions-cit-mit-overview.md

## Handle failures — Payabli does not auto-retry

**Payabli does not retry a failed autopay.** Implement retry/dunning yourself: listen for the `DeclinedPayment` webhook, find the subscription via the transaction's schedule reference, then update the method and retry or notify the customer. Pause with `PUT /Subscription/{subId}` (`setPause: true`); skip a cycle with `totalAmount: 0`. https://docs.payabli.com/guides/pay-in-developer-subscriptions-utilities.md

Most autopay declines are expired cards — keeping stored cards current with the Card Account Updater (a paid add-on; see `payabli-tokenization`) heads off many of them.

## Boundaries

- One-time charges and the payment surfaces → `payabli-accept-payments`
- Saving the payment method → `payabli-tokenization`
- Receiving the `DeclinedPayment` event → `payabli-webhooks`
