---
name: payabli-invoices
description: >-
  Use when sending invoices and collecting payment from customers — invoice
  creation and delivery (email, SMS, or link), customer-facing payment links, or
  Pay By SMS. Taking the payment itself lives in payabli-accept-payments; paying
  vendors lives in payabli-bills. Reads payabli-integration.md on load if present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli invoices and payment links

Bill customers and collect payment.

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## On load

If `payabli-integration.md` exists at the repo root, read it; honor its `## SDK` value.

## Create and send an invoice

`POST /Invoice/{entry}` creates an invoice; the invoice number must be unique within the paypoint, and it links to a customer (create the customer first and pass `customerId`). Each line item must include `itemMode` and `itemTotalAmount` (the per-line total), or create fails with `Invalid item data`. Email it with `GET /Invoice/send/{idInvoice}` (`attachfile=true` to attach a PDF), and list invoices with `GET /Query/invoices/{entry}`. https://docs.payabli.com/guides/pay-in-developer-invoices-manage.md

## Customer-facing payment links

Generate a link from an invoice with `POST /PaymentLink/{idInvoice}`, then deliver it with `POST /PaymentLink/push/{payLinkId}` by email or SMS. The generate call takes a full page-configuration body and returns only the link id; assemble the URL as `https://app-sandbox.payabli.com/payment-link/{entry}/{payLinkId}` (`app.payabli.com` in production). Copy the guide's config example. https://docs.payabli.com/guides/pay-in-developer-payment-links-manage.md

## Pay By SMS

A paid add-on (requires Payabli enablement). The customer must opt in before receiving payment SMS (they opt out by replying STOP), and SMS payment links expire after 3 days. https://docs.payabli.com/guides/pay-in-developer-invoices-pay-by-sms.md

## Choose a delivery approach

- **Native invoicing** — Payabli runs the full create/deliver/track lifecycle; zero PCI burden.
- **Custom UI + embedded components** — your design, reduced PCI scope.
- **Custom UI + payment links** — your design, redirect to a Payabli-hosted page.

Confirm payment with the `InvoicePaid` webhook rather than polling. https://docs.payabli.com/guides/pay-in-invoicing-delivery-decision.md

## Boundaries

- The payment surfaces and embedded components → `payabli-accept-payments`
- Recurring billing → `payabli-subscriptions`
- Paying vendors (money out) → `payabli-bills`
