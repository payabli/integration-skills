---
name: payabli-customers
description: >-
  Use when working with Payabli customer records — creating, reading,
  listing or searching, updating, or deleting customers, or showing a
  customer's transaction history (any CRM or customer portal). Covers the
  Customer API and customer queries. Money movement lives in
  payabli-accept-payments, saved payment methods in payabli-tokenization,
  recurring billing in payabli-subscriptions, and Pay Out vendors in
  payabli-vendors. Reads payabli-integration.md on load if present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli customers

Manage the Pay In customer lifecycle: create, read, list/search, update, delete, and transaction history.

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## On load

If `payabli-integration.md` exists at the repo root, read it; honor its `## SDK` value.

## Customers are per-paypoint and usually the first call

Each paypoint keeps its own customer list — customers aren't shared across paypoints. A customer is usually the first thing you create, since you can't run a charge without one. https://docs.payabli.com/guides/pay-ops-developer-customers-manage.md

## Create a customer

`POST /Customer/single/{entry}`. The body is **flat** — `firstname`, `lastname`, `email`, and the rest sit at the top level, *not* wrapped in `customerData` the way the transaction endpoints nest them. Pass `replaceExisting: 1` to overwrite a matched record.

**Custom identifiers drive matching — read the config before your first create.** A create or update must supply a value for at least one of the paypoint's configured identifier fields, named in an `identifierFields` array (reads and deletes use `customerId` in the path and don't need it). Which fields count is configured per paypoint, so pull them first with `GET /Paypoint/settings/{entry}` rather than assuming `email`/`customerNumber`; if the request supplies no value for any configured identifier, the call returns `400 Invalid customer identifiers`. When a paypoint has none configured, matching falls back to `customerNumber`. The configured set also decides whether a create dedupes onto an existing record or makes a new one. See `payabli-fundamentals` → Customer identifiers. https://docs.payabli.com/guides/pay-ops-developer-customers-manage.md

**Casing gotcha:** requests take lowercase fields (`firstname`, `lastname`, `email`, `phone`, `address1`), but responses return them PascalCase (`Firstname`, `Lastname`, `Email`, `Phone`, `Address1`) alongside camelCase IDs (`customerId`, `customerNumber`, `customerStatus`). Map case-insensitively rather than assuming one casing across the round trip.

**Response envelopes differ by operation — check the shape per call.** Create (`POST /Customer/single/{entry}`) returns `{ isSuccess, responseData }`; read (`GET /Customer/{customerId}`) returns the customer record **bare** (no wrapper); list (`GET /Query/customers/{entry}`) returns `{ Summary, Records }`. Don't assume a uniform envelope across the three.

## Read, update, delete

Read one with `GET /Customer/{customerId}`, update with `PUT /Customer/{customerId}`, and delete with `DELETE /Customer/{customerId}`. The `customerStatus` field is an integer (`0` inactive, `1` active, `85` locked, `-99` deleted). https://docs.payabli.com/guides/pay-ops-developer-customers-manage.md A customer's saved payment methods come back on this record as a top-level `StoredMethods[]` array (each with its `IdPmethod` — the value you charge as `storedMethodId`) — there is no separate token-list or Query route for them; see `payabli-tokenization`.

## List and search customers

`GET /Query/customers/{entry}`, or `GET /Query/customers/org/{orgId}` for organization-wide results. Filter with `fieldName(condition)=value` (for example `email(eq)=...`, `lastname(ct)=...`, `customernumber(eq)=...`, `status(in)=1|0`) and paginate with `fromRecord`/`limitRecord`. The response wraps results in `{ Summary, Records }`. For the full filter syntax, operators, and exports, use `payabli-reporting` rather than reinventing them.

**Unrecognized filter fields are silently ignored — the query then returns every record.** Field names also differ per endpoint: the customer-number filter is `customernumber` on `/Query/customers` but `customerNumber` on `/Query/transactions`. Use the exact field name from that endpoint's API reference and **verify the result count actually narrowed**, since a bad field name fails silently rather than erroring. See `payabli-reporting`. https://docs.payabli.com/guides/pay-ops-developer-customers-manage.md

## Customer transaction history

To show a customer's history, query the transactions endpoint filtered by customer: `GET /Query/transactions/{entry}?customerId(eq)=...` (or `customerNumber(eq)=...`). Each record carries a numeric `TransStatus`; decode it from the [Pay In status reference](https://docs.payabli.com/guides/pay-in-status-reference.md) when rendering history.

## Boundaries

- Charging a customer and the payment surfaces → `payabli-accept-payments`
- Saving a payment method on a customer → `payabli-tokenization`
- Recurring charges → `payabli-subscriptions`
- Pay Out vendors (the vendor equivalent of this skill) → `payabli-vendors`
- Query filter syntax, exports, and reconciliation → `payabli-reporting`
