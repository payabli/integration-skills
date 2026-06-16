---
name: payabli-disputes
description: >-
  Use when handling chargebacks or transaction returns on Payabli — responding
  to disputes, submitting evidence, processing ACH return codes, or recovering
  from a failed refund. Routine voids/refunds of healthy transactions are NOT
  here — those live in payabli-accept-payments. Reads payabli-integration.md on
  load if present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli disputes (chargebacks & returns)

Handle money coming back out after the fact: chargebacks, ACH returns, and failed refunds.

Disputes and returns **originate externally** — a cardholder or bank starts a chargeback, the processor returns an ACH debit. Through the API you can only **read and respond**, never create them. Read both through `GET /Query/chargebacks` (a record's `Method` and status distinguish a card chargeback from an ACH return). In sandbox, chargebacks are simulated by a manual import in the Payabli Portal. To simulate an ACH return, contact your Payabli Solution Engineer with the transaction IDs of the ACH transactions you want turned into returns — there's no self-serve API or Portal flow for it.

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## On load

If `payabli-integration.md` exists at the repo root, read it; honor its `## SDK` value.

## Chargebacks

When a cardholder disputes a charge, the funds are debited immediately and a fee applies. You have a limited window (about 10 days) to respond with evidence via `POST /ChargeBacks/response/{Id}` — transaction receipt, customer communication, terms accepted, and transaction-specific proof. You cannot refund a transaction once its chargeback is initiated. https://docs.payabli.com/guides/pay-ops-disputes-chargebacks-returns-overview.md

## ACH returns

Returned ACH debits carry return codes (for example R01 insufficient funds, R02 account closed, R10 unauthorized). Monitor your return rates — exceeding network thresholds risks suspension. https://docs.payabli.com/guides/pay-ops-transfers-ach-returns.md

## Failed refunds

A failed refund — especially ACH — usually surfaces later as an ACH return, not an immediate error. If a refund fails, confirm it was initiated correctly for the right transaction, then make the customer whole another way (store credit, check, or another method). Card refunds rarely fail. https://docs.payabli.com/guides/pay-in-refunds-failures-overview.md

## Boundary

Voiding or refunding a **healthy** transaction (the normal reversal decision) is **not** this skill — that's `payabli-accept-payments`. This skill is for chargebacks, returns, and recovering from a refund that failed.
