---
name: payabli-webhooks
description: >-
  Use when writing or modifying a webhook handler for Payabli events — receiving
  and processing event payloads, acknowledging delivery, authenticating incoming
  webhooks, handling retries idempotently, configuring event subscriptions,
  routing events across multiple paypoints, or weighing the webhooks-vs-polling
  tradeoff. Reads payabli-integration.md on load if present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli webhooks

Receive Payabli events, acknowledge them, and process them safely.

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## On load

If `payabli-integration.md` exists at the repo root, read it; honor its `## Webhooks` scope and `## Paypoint model`.

## How delivery works

An event is queued and POSTed to your endpoint; **return HTTP 200 to acknowledge**. If you don't return success, Payabli retries (a small number of times, minutes apart), then marks the delivery failed and exposes it for manual retry. Treat retries as expected, not exceptional. https://docs.payabli.com/guides/pay-ops-notifications-webhooks-overview.md

## Authenticate the webhook — there is no signature

**Payabli does not sign webhook payloads.** There is no HMAC or signature to verify — do not implement signature verification. Authenticate incoming webhooks two ways instead:

1. Set a custom `Authorization` header (via `webHeaderParameters`) when you create the notification, and check it on receipt.
2. Allowlist Payabli's documented sending IP addresses (listed in the webhooks overview, and they differ by environment).

`webHeaderParameters` lives inside `content` and is an array of `{key, value}` pairs. Payabli sends whatever you configure **verbatim** — there is no signing or token scheme, so the value is just your shared secret as-is (no `Bearer`/`Basic` prefix is required or interpreted). Check for the exact same string on receipt:

```json
"content": {
  "eventType": "ApprovedPayment",
  "webHeaderParameters": [
    { "key": "Authorization", "value": "<your-shared-secret>" }
  ]
}
```

For **local development only**, you can accept deliveries when no secret is configured, so a missing header doesn't block testing. In any deployed environment, fail closed: require the header and reject (and log) deliveries that don't match.

For money-critical events, do not trust the payload alone: confirm by re-querying the transaction via the API (correlate on `transId`). This is the same discipline as idempotency in `payabli-fundamentals`.

## Process idempotently

Retries and at-least-once delivery mean you will see duplicates. Dedupe on event identity (for example `transId`) and make handling idempotent so a repeat delivery is a no-op.

## Configure a subscription

Create a notification with `POST /Notification`:

- `ownerType` — `0` for organization/partner, `2` for paypoint.
- `ownerId` — the numeric ID of that owner: the `orgId` when `ownerType` is `0`, the `paypointId` when `ownerType` is `2`. This is the numeric entity ID, **not** the entrypoint alias used in URL paths.
- `method: web`, `target` = your endpoint URL, `content.eventType` = the event to subscribe to, and `webHeaderParameters` for your auth header.

https://docs.payabli.com/guides/pay-ops-developer-notifications-manage.md

Event names and payload shapes: https://docs.payabli.com/guides/pay-ops-webhooks-payloads.md

## Local development

Payabli must POST to a publicly reachable URL, so `localhost` won't receive deliveries. Expose your handler with a tunnel and set the notification `target` to the tunnel's public HTTPS URL plus your handler path. **localhost.run** is the lowest-friction option — no account or install, just SSH: `ssh -R 80:localhost:3000 nokey@localhost.run` prints a public HTTPS URL (use your handler's port). ngrok and cloudflared also work. The auth header travels in the subscription's `webHeaderParameters`, not in the request you make from your app. Redo two things when they change: if the tunnel URL rotates (it does each restart on the free tiers), update `target`; if you rotate the shared secret, update `webHeaderParameters` too — the secret is baked into the subscription, not read live.

Not every event can be triggered on demand in sandbox: payment-event webhooks fire when you run the transaction, but chargebacks, ACH returns, and similar require Payabli to trigger them (see `payabli-testing`).

## Route across multiple paypoints

Subscribe at the **organization** level (`ownerType: 0`, `ownerId` = the `orgId`) to cover all paypoints, or per **paypoint** (`ownerType: 2`, `ownerId` = the `paypointId`). Configuring the same event at both levels delivers duplicates. Use `internalData` to tag events with a routing key when one endpoint serves many paypoints.

## Webhooks vs. polling

Use webhooks for real-time reactions (payment approved, payout paid, invoice paid). Use polling for reconciliation, backfill, and audits. https://docs.payabli.com/guides/pay-ops-notifications-webhooks-vs-polling.md

Building it end to end: https://docs.payabli.com/guides/pay-ops-developer-webhooks-quickstart.md
