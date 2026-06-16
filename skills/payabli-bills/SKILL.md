---
name: payabli-bills
description: >-
  Use when building accounts-payable automation on Payabli — capturing vendor
  bills (manual entry or OCR), routing them through approval, and paying them
  through Pay Out. Distinct from raw payouts (payabli-send-payments): a bill
  starts with a vendor invoice that may need approval before payment. Reads
  payabli-integration.md on load if present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli bills (AP automation)

Capture vendor bills, approve them, and pay them.

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## On load

If `payabli-integration.md` exists at the repo root, read it; honor its `## SDK` value.

## Capture a bill

Create a bill with `POST /Bill/single/{entry}` — identify the vendor by `vendorNumber` (required), plus amount, due date, and an optional bill image. A bill needs only a top-level `netAmount`; unlike invoices, line items aren't required. Bulk-import with `POST /Import/billsForm/{entry}`. https://docs.payabli.com/guides/pay-out-developer-bills-manage.md

Set `status: 1` (Active) on create so the bill is immediately payout-eligible. `-99` is **Cancelled** — don't use it.

**Bill OCR is a standalone capture path** — Payabli's OCR engine extracts bill data (line items, amounts, vendor details) from a PDF or image. It is its own feature, not part of vendor enrichment. Extract via `POST /Import/ocrDocumentForm/{typeResult}` (multipart) or `/Import/ocrDocumentJson/{typeResult}` (base64), with `typeResult` set to `bill`. https://docs.payabli.com/guides/pay-ops-developer-ocr-use.md

## List bills

List bills with `GET /Query/bills/{entry}`. Filter by `vendorNumber(eq)` or `vendorId(eq)` — **`idVendor(eq)` is silently ignored and returns every bill**, so never use it to scope to a vendor. Query basics (filter syntax, pagination) → `payabli-reporting`.

## Approve (optional)

Approval is optional. A bill must be `Active` or `Approved` to be paid; a bill `Pending Approval` is blocked. Send for approval with `POST /Bill/approval/{idBill}` (body: a JSON array of approver emails, for example `["approver@example.com"]`); if an approver isn't a Payabli user yet, add `?autocreateUser=true` so the call creates them — without it the call returns `400 "Empty approvals"`. Then approve or reject with `GET /Bill/approval/{idBill}/{approved}`.

## Pay the bill

Bills are paid through Pay Out — see `payabli-send-payments`. One payout can pay multiple bills for the same vendor. (A raw payout can skip bill creation with `doNotCreateBills: true`.)

## Bills vs. invoices

A **bill** is money **out** (a vendor's invoice that you pay); an **invoice** is money **in** (you billing a customer — `payabli-invoices`). https://docs.payabli.com/guides/platform-bills-vs-invoices.md

## Boundaries

- Payout mechanics, vendors, and vendor enrichment → `payabli-send-payments`
- Customer-facing invoices → `payabli-invoices`
