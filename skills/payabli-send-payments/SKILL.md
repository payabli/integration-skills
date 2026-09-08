---
name: payabli-send-payments
description: >-
  Use when the developer is sending money out through Payabli — paying vendors
  via payout. Covers the MoneyOut flow, managed vs. on-demand payables, vendors
  and vendor enrichment, reissue, ghost cards, and Positive Pay. AP automation
  (bills and OCR) lives in payabli-bills. Reads payabli-integration.md on load if
  present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli send payments (Pay Out)

Pay vendors and other recipients.

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## On load

If `payabli-integration.md` exists at the repo root, read it; honor its `## SDK` value and `## Pay Out` scope.

## The decision is managed vs. on-demand — not the method

Ask the partner whether they want **managed** or **on-demand** payables. Do not ask them to pick a payment method or lead with one.

- **Managed payables** — a Payabli service: Payabli's team contacts each vendor and works through vCard → ACH → check. It is a service, not a payment method.
- **On-demand** — the partner pays now and owns vendor enablement.

The payment **method (vCard, ACH, check) is the vendor's choice**, set on the recipient side (at enrollment, or via managed-payables outreach). https://docs.payabli.com/guides/pay-out-payables-overview.md · https://docs.payabli.com/guides/pay-out-managed-payables-overview.md

For an **on-demand vCard** payout, set the authorize body's `paymentMethod.method` to the literal `"vcard"`. Don't use `"managed"` — that selects the managed-payables service, not a virtual card. Follow the authorize reference for the rest of the shape.

## Make a payout

Authorize a payout with `POST /MoneyOut/authorize`. Note the asymmetry with Pay In: MoneyOut is **not versioned** (no `/v2`), unlike `/v2/MoneyIn/*`. One easy-to-miss gotcha: an authorize `invoiceData` item references an **existing bill by `billId` only** — create the bill first with `POST /Bill/single`, then pass `invoiceData: [{ billId }]`. The item takes no `netAmount`; follow the authorize reference for the rest of the shape. **`autoCapture: true` is the recommended approach** — it captures asynchronously after authorization, so the authorize response confirms only authorization; confirm capture via the `payout_transaction_approvedcaptured` webhook. Use `MoneyOut/captureAll` to capture many at once. When you render a payout's state, read the `PaymentStatus` string rather than the numeric `Status` (see `payabli-reporting`). https://docs.payabli.com/guides/pay-out-developer-payouts-manage.md

For ACH payouts, `paymentMethod.achHolder` accepts **letters and spaces only** — digits, hyphens, or other special characters return `400 "Account holder name cannot contain special characters"`. Use the real account-holder name; don't reuse a tagged `vendorNumber` (like `acme-20260901-001`) as the holder.

**Pay Out must be enabled on the paypoint, and only Payabli can enable it.** A `Missing Gateway Data ... group moneyout` error is **always** a configuration issue — Pay Out isn't enabled on the paypoint — and only Payabli can fix it. Contact the Payabli team to get Pay Out enabled.

## There are no Pay Out refunds

**Pay Out does not support refunds.** Cancel a payout before it is `processed`; once processed, it cannot be reversed. To change the payment method, **reissue** — this creates a new payout linked to the original. https://docs.payabli.com/guides/pay-out-developer-payouts-reissue.md

## Vendors

Create a vendor with `POST /Vendor/single/{entry}` — it returns the new vendor's id directly in `responseData` as an integer (unlike customer creation, which returns `responseData.customerId`), so parse accordingly. **Vendor enrichment** (opt-in) uses AI to populate a vendor's payment-acceptance and contact details from invoices and the web — this is separate from bill OCR. https://docs.payabli.com/guides/pay-out-developer-vendors-manage.md · https://docs.payabli.com/guides/pay-out-vendor-enrichment-overview.md

## Other capabilities

- Ghost cards (multi-use vCards): https://docs.payabli.com/guides/pay-out-developer-ghost-cards-manage.md
- Vendor self-enrollment payment links — generate the link from the bill with `POST /PaymentLink/bill/{billId}`, then deliver it with `GET /PaymentLink/send/{payLinkId}?mail2=<email>`. `POST /PaymentLink/push` is **invoice-only** and returns `400 "Payment link must be for an invoice"` on a bill/payout link — use `send`, not `push`, for these. https://docs.payabli.com/guides/pay-out-developer-payment-links-manage.md
- Positive Pay (check fraud control): https://docs.payabli.com/guides/pay-out-checks-positive-pay.md
- Payout subscriptions (recurring payouts): https://docs.payabli.com/guides/pay-out-developer-payout-subscriptions-manage.md
- ACH transfer returns: https://docs.payabli.com/guides/pay-ops-transfers-ach-returns.md

Wire and RTP are on the roadmap — not yet generally available.

## Boundaries

- AP automation (bills, bill OCR) → `payabli-bills`
- Saving a vendor's method as a token → `payabli-tokenization`
