---
name: payabli-vendors
description: >-
  Use when working with Payabli vendor records — creating, reading,
  listing or searching, updating, or deleting vendors, or showing a
  vendor's payment history (an AP directory, vendor portal, or supplier
  management screen). Covers the Vendor API and vendor queries. Sending
  payouts lives in payabli-send-payments, bill/AP automation in
  payabli-bills, saved payout methods in payabli-tokenization, and Pay In
  customers in payabli-customers. Reads payabli-integration.md on load if
  present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli vendors

Manage the Pay Out vendor lifecycle: create, read, list/search, update, delete, and payment history.

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## On load

If `payabli-integration.md` exists at the repo root, read it; honor its `## SDK` value.

## Vendors are per-paypoint and required before payouts

Vendors are the entities that get paid in Pay Out. Each paypoint keeps its own vendor list — vendors aren't shared across paypoints — and a vendor must exist before you can bill or pay it. Payabli supports US and Canadian vendors only. https://docs.payabli.com/guides/pay-out-developer-vendors-manage.md

## Create a vendor

`POST /Vendor/single/{entry}`. `vendorNumber` is **required and must be unique within the paypoint** (a string like `VEN-123`, not a bare integer). `name1` is also required.

**Address is all-or-nothing.** If you send any address field, the full set (`address1`, `city`, `state`, `zip`) must be present and valid; the primary address and the remittance address are validated independently. `state` is checked against `country` (`US` states or `CA` provinces only).

**Casing gotcha:** requests take lowercase fields (`vendorNumber`, `name1`, `email`, `phone`, `address1`), but responses return them PascalCase (`VendorNumber`, `Name1`, `Email`, `Address1`, `VendorId`). Vendor status has three forms depending on context — the request field is `vendorStatus`, the query filter is `status`, and the response field is `VendorStatus`. Map case-insensitively rather than assuming one casing.

## Read, update, delete

Read one with `GET /Vendor/{idVendor}`, update with `PUT /Vendor/{idVendor}`, and delete with `DELETE /Vendor/{idVendor}`. A vendor's saved payout methods come back on this record as a top-level `StoredMethods[]` array (each with its `IdPmethod` — the value you pay as `storedMethodId`) — there is no separate token-list or Query route for them; see `payabli-tokenization`.

## List and search vendors

`GET /Query/vendors/{entry}`, or `GET /Query/vendors/org/{orgId}` for organization-wide results. Filter with `fieldName(condition)=value` (for example `vendorNumber(eq)=VEN-123`, `name(ct)=supply`, `status(in)=1|0` — the status filter field is `status`, not `VendorStatus`) and paginate with `fromRecord`/`limitRecord`. The response wraps results in `{ Summary, Records }`. For the full filter syntax, operators, and exports, use `payabli-reporting`. https://docs.payabli.com/guides/pay-out-developer-vendors-manage.md

## Vendor payment history

To show a vendor's payment history, query the payouts endpoint filtered by vendor: `GET /Query/payouts/{entry}?vendorNumber(eq)=...` (or `vendorId(eq)=...`). Each record carries a numeric payout transaction status; decode it from the [Pay Out status reference](https://docs.payabli.com/guides/pay-out-status-reference.md) when rendering history.

## Vendor enrichment

Payabli can auto-fill vendor payment and contact details from invoices and the web (a beta feature). If a task calls for it, point to the enrichment guide rather than hand-rolling it. https://docs.payabli.com/guides/pay-out-vendor-enrichment-overview.md

## Boundaries

- Creating and sending payouts → `payabli-send-payments`
- Bill capture and AP approval flows → `payabli-bills`
- Saving a payout method on a vendor → `payabli-tokenization`
- Pay In customers (the customer equivalent of this skill) → `payabli-customers`
- Query filter syntax, exports, and reconciliation → `payabli-reporting`
