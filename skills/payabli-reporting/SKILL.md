---
name: payabli-reporting
description: >-
  Use when an agent needs the Query API — to build reports and exports,
  reconcile batches, track settlement, or back a list/detail data UI such as
  a customer's transaction history. Explains the filter syntax, pagination,
  and the response envelope. Reads payabli-integration.md on load if present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli reporting

Query and export Payabli data, and reconcile settlements.

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## On load

If `payabli-integration.md` exists at the repo root, read it; honor its `## SDK` value.

## Query the API

Query records — transactions, payouts, batches, settlements, customers, vendors, chargebacks — by entry (paypoint) or organization. Filters use `fieldName(condition)=value` (operators include `eq`, `gt`, `lt`, `ne`, `ct`, `in`, and others). Export directly with `exportFormat=csv` or `exportFormat=xlsx`. https://docs.payabli.com/guides/pay-ops-reporting-overview.md

Transaction records return numeric status codes. To render a transaction list or history view, map `TransStatus` (payment status) and `SettlementStatus` (funding status) to their meanings with the Pay In status reference. https://docs.payabli.com/guides/pay-in-status-reference.md

For **payout** records, prefer the `PaymentStatus` string over the numeric `Status` — the payout status enum has values the reference doesn't list, so mapping the integer alone can render "unknown." https://docs.payabli.com/guides/pay-out-status-reference.md

Bind a payout data UI to the record's actual keys: the id is `PaymentId` (a ULID) or `IdOut` (integer), the method is `PaymentMethod` (a string like `"vcard"`), and the description is `Comments` — not `orderDescription`.

## Query basics

Every Query endpoint shares the same mechanics, so a list or detail view is just a filtered query:

- **Filter** with `fieldName(condition)=value`. Conditions include `eq` (or empty), `ne`, `gt`, `ge`, `lt`, `le`, `ct` (contains), `nct`, and `in`/`nin` (pipe-separated, for example `status(in)=1|0`). Repeat the pattern to AND multiple filters. The accepted field list is per-endpoint — check that endpoint's API reference.
- **Paginate** with `limitRecord` (page size; `0` or a negative value returns all) and `fromRecord` (offset).
- **Response envelope:** results come back as `{ Summary, Records }` — `Records` is the array, and `Summary` carries `totalRecords` and `totalPages` for paging.

Filters are bare query params (`?status(in)=1|0`). The API reference models the whole filter set as one `parameters` object — an OAS representation limit — so a request copied from the console comes prefixed with `parameters=`, which Payabli ignores, silently returning the full unfiltered set. Strip the literal `parameters=` before sending, and sanity-check that the returned count actually narrowed.

Confirm the count in both directions, not just against over-returning. An unrecognized or mis-cased filter field may be ignored (returning the full set) or return no records, so treat a `0` result as a possible bad filter rather than a definitive empty set — particularly on a list a user acts on, such as disputes. Filter field names are **case-sensitive** and can differ from the PascalCase fields in the response (filter `caseNumber`, not `CaseNumber`); use the exact field name documented for that endpoint.

Embedded summary objects (for example `customerSummary` on a customer record) may come back `null` — don't assume they're populated.

## Scriptable exports: the Query CLI

For repeatable or batch exports, use the Payabli Query CLI — an open-source tool that wraps the Query API. https://docs.payabli.com/developers/platform-developer-query-cli.md

## Reconcile settlements

Query batches, inspect each batch's `Transfer` object (for example `ReturnedAmount`, `ChargeBackAmount`), then pull transfer details for line-by-line adjustments (holds, releases, fees). https://docs.payabli.com/guides/pay-ops-developer-transfers-reconcile.md

## Scheduled reports

Reports can be delivered on a schedule via notifications (`report-email` or `report-web`). Set these up the same way as other notifications — see `payabli-webhooks`.

## Boundary

Real-time, per-event delivery (reacting the moment something happens) → `payabli-webhooks`. Use reporting for pulls, exports, and reconciliation.
