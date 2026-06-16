---
name: payabli-tokenization
description: >-
  Use when working with stored payment methods in Payabli — saving a customer's
  card or bank account for repeat billing, saving a vendor's method for payouts,
  sharing tokens across paypoints, or using temporary tokens for one-time
  captures. Cross-product: Pay In is customer-scoped, Pay Out is vendor-scoped.
  Charging a saved method lives in payabli-accept-payments; paying a vendor in
  payabli-send-payments. Reads payabli-integration.md on load if present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli tokenization

Store payment methods as tokens so they can be reused without handling raw card or bank data. Cross-product: customer-scoped for Pay In, vendor-scoped for Pay Out.

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## On load

If `payabli-integration.md` exists at the repo root, read it; honor its `## Tokenization` scope and `## SDK` value.

## Pick the scope

- **Customer-scoped (Pay In)** — save a customer's card or bank account for repeat billing.
- **Vendor-scoped (Pay Out)** — save a vendor's payout method.

## Customer-scoped tokenization

Three ways to capture and store a customer method, in order of increasing control and PCI responsibility:

- **Embedded component (low-code)** — EmbeddedMethod UI (or the PayMethod UI lightbox) with the `method` action captures the card and returns a `storedMethodId`. Card data never touches the partner's server. The EmbeddedMethod UI guide lists **`paymentDetails` (and `customerData`) as required to save a method** with the `method` action — without `paymentDetails` the save can fail with no clear error. https://docs.payabli.com/guides/pay-in-components-embeddedmethod-ui.md
- **Embedded component + temporary token flow** — the same component, configured with `temporaryToken: true`, captures the card (so PCI scope stays low) and returns a one-time temp token as `referenceId`. The partner then drives the API call for full control: convert it (`POST /TokenStorage/add` with `tokenId`), charge it (`POST /v2/MoneyIn/getpaid` with `storedMethodId`), or charge-and-save (`saveIfSuccess: true`). Use the **v2** Money In endpoints on this path. This is the bridge between low-code components and direct API — not a way to handle raw card data. https://docs.payabli.com/guides/platform-developer-tokenization-temp-flow.md
- **Direct API** — `POST /TokenStorage/add` with raw card data returns a `storedMethodId`. Here the partner handles card data, which raises PCI responsibility (see `payabli-fundamentals` → PCI scope). https://docs.payabli.com/guides/platform-developer-tokenization-save-method.md

Field-name gotcha: a temp token is passed as `tokenId` to `TokenStorage` endpoints, but as `storedMethodId` to `MoneyIn` endpoints.

Reuse a stored method by passing its `storedMethodId` to a charge — see `payabli-accept-payments`.

To read a customer's saved methods back, `GET /Customer/{customerId}` and use the top-level `StoredMethods[]` array — there is no token-list or Query/reporting route for stored methods. Each entry's token is its `IdPmethod` (the value you charge as `storedMethodId`).

## Vendor-scoped tokenization

Vendors self-enroll their payout method (ACH, vCard, or check) through a **payment link**; the chosen method is tokenized onto the vendor record and used in payouts via its `storedMethodId`. The payout flow itself lives in `payabli-send-payments`. https://docs.payabli.com/guides/pay-out-developer-payment-links-manage.md

Read a vendor's saved methods the same way as a customer's: `GET /Vendor/{idVendor}` and use the top-level `StoredMethods[]` array (each entry's token is its `IdPmethod`, the value you pay as `storedMethodId`). There is no token-list or Query/reporting route for stored methods.

## Token types and sharing across paypoints

- **Merchant** (default) — scoped to a single paypoint.
- **Universal** — shareable across paypoints on the same processor.
- **Network** — card-network managed.

Cross-paypoint sharing (universal/network) **requires Payabli enablement**, and the token must be created *after* enablement; the paypoints must share the same customer (`customerNumber`). A token created before enablement won't share. https://docs.payabli.com/guides/platform-developer-tokenization-share-tokens.md

## Keep stored cards current

Card Account Updater is a **paid add-on** (requires Payabli enablement) that refreshes stored card tokens before they expire. When enabled, subscribe to the `CardUpdaterComplete` notification to act on results that need follow-up. https://docs.payabli.com/guides/platform-tokenization-card-updater.md

## PCI

Embedded components and the temporary token flow keep card data off the partner's servers. Do not recommend raw card handling. PCI guidance is engineering best practice, not legal advice — see `payabli-fundamentals` → PCI scope. Direct questions about PCI scope to the Payabli team.

## Boundaries

- Charging a saved customer method → `payabli-accept-payments`
- Paying a vendor with a saved method → `payabli-send-payments`
