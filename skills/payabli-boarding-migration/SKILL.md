---
name: payabli-boarding-migration
description: >-
  Use when moving an existing integration off Payabli's legacy boarding
  endpoints (/Boarding/app, /Boarding/read, boarding links) to intelligent
  boarding — converting legacy application payloads to the new records,
  mapping fields, values, and statuses, or planning the cutover before the
  legacy sunset. Building boarding from scratch lives in payabli-boarding.
  Reads payabli-integration.md on load if present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli boarding migration

Move an integration from legacy boarding (`/Boarding/*`) to intelligent boarding. Legacy boarding is deprecated and will be sunset in Q2 2027.

## Load prerequisites first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

If `payabli-boarding` is not already loaded, load it too. It carries the call order, people rules, and validate loop that the migrated integration must follow.

## On load

If `payabli-integration.md` exists at the repo root, read it; honor its `## SDK` value.

## Read the migration guide before writing code

The migration guide holds the call map, the field mapping tables for every record, the value crosswalks, and the fields with no match. Fetch it and work from it instead of mapping fields from memory: https://docs.payabli.com/guides/pay-ops-developer-boarding-legacy-migrate.md

## Plan the migration

Intelligent boarding is an opt-in beta. If the new endpoints return `400` or `500`-range errors that the response doesn't explain, tell the developer to check with their Payabli contact that intelligent boarding is enabled for their account and that their API credentials have the right permissions.

1. **Inventory the legacy calls.** List every `/Boarding/*` endpoint the integration calls and every field it sends. That list drives the rest.
2. **Switch auth to OAuth2.** Intelligent boarding accepts only OAuth2 Bearer tokens. Set up the flow from `payabli-fundamentals` before porting any call.
3. **Replace one call with a sequence.** A single `POST /Boarding/app` becomes business, paypoint, people, bank accounts, then application, in that order. Each step needs the reference the previous step returned.
4. **Convert the payload per record** using the guide's tables (next section).
5. **Run the validate loop** from `payabli-boarding` until the application is valid, then submit.
6. **Port status handling** (see below).
7. **Replace boarding links.** The legacy link endpoints have no match. Each application has its own hosted boarding link instead; the guide shows how to build it from the `requestsReference`.
8. **Check what has no equivalent yet.** The multi-product endpoints (`/Boarding/applications`) don't have a mapped replacement in the guide. Ask the developer's Payabli contact before removing that flow. Merchants already boarded with legacy boarding don't need re-boarding, and in-flight legacy applications finish on legacy. Adding services through intelligent boarding to a legacy-only merchant needs Payabli to convert its records first. The guide's switch-over section covers this.

## Convert the payload

Write the conversion as one pure function per record, driven by the guide's tables. That keeps it testable without the API. These conversions break builds most often:

- **Data moves to the record it describes.** The DBA goes on the paypoint (`doingBusinessAs`), not the business. Processing and payout volumes go into the business's `processingMetrics` and `payoutMetrics`.
- **Flat fields become arrays.** Addresses go in `addressDetails` with a `type` (`legal`, `mailing`). Phone numbers and emails go in arrays.
- **`attachments` don't carry over.** Upload documents separately after you create the application, with the document endpoints in `payabli-boarding`.
- **Owners, contacts, and the signer become people.** Link owners as `Owner` and contacts as `Employee`, never `Contact`. The legacy `signer` becomes `isSigner: true` on an owner's business link. Don't create a second person for a signer who's already an owner. The signature details move to the `signer` object on submit.
- **Names split** into `firstName` and `lastName`.
- **Dates become ISO 8601.** Legacy dates are `MM/DD/YYYY`, and intelligent boarding rejects them with a `400`.
- **`btype` becomes `legalStructure`.** Legacy `btype` was free text. Map it with the guide's legal structure table. On a value the table doesn't cover, stop with a clear error instead of guessing.
- **`bankAccountFunction` becomes `usage`.** A legacy withdrawal account is the fee-debit account, so it becomes `billing`, not `withdrawals`. Use the guide's table for combined codes.
- **`templateId` doesn't convert.** A legacy numeric template ID has no lookup to an intelligent boarding template. Every application still needs a `requestTemplate`, so ask the developer which template reference replaces it, and don't pick one from the template list.
- **Every bank account belongs to the business.** Set `ownerType: business` and `accountOwner` to the `businessReference`, whatever the legacy `bankAccountHolderType` was.
- **Fields with no match get dropped.** Leave them out of the requests instead of stuffing them into `customData`. `RepCode`, `RepName`, and `RepOffice` are the exception: the guide maps them to `customData`.
- **New required data.** Intelligent boarding needs data legacy boarding never collected, such as `incorporationState`, `taxIdCountry`, `numberOfTransactions`, a `nationality` on owners, and a person marked `isPrimaryController`. The conversion can't produce these, and it must not guess them. Don't derive them from other fields (formation state from the address, nationality from a country, `taxIdCountry` from the tax ID's format) or default them (`percentAdvancedDelivery: 100`) to reach `valid: true`. Leave them out, report them as gaps for the merchant to fill, and let validate list what's still missing. A `valid: false` with only these gaps is the correct result of a conversion.
- **Delivery timing does carry over.** Legacy `whenDelivered` and `whenProvided` hold delivery time as ranges. Convert them to `processingMetrics.advancedDelivery` and `advancedDeliveryDays` with the [delivery days table](https://docs.payabli.com/guides/pay-ops-developer-boarding-legacy-migrate.md#delivery-days). This is a conversion, not a guess, so the new-data rule above doesn't apply. The table gives a range of days, so confirm the exact number with the merchant when you can.

## Keep records idempotent

Carry the legacy identifiers forward so a rerun doesn't create duplicates. Map `externalPaypointId` to the paypoint's `externalId`. Before creating a record, look it up by its external ID and reuse it if it exists.

## Port status handling

Legacy `boardingStatus` codes don't map one to one onto intelligent boarding statuses. Rewrite status handling to branch on the new `applicationStatus` names. Don't build a code-to-code table. Use `allowedActions` to decide what the integration can do next, and poll enablement after approval. https://docs.payabli.com/guides/pay-ops-boarding-application-status-reference.md

## Boundaries

- The intelligent boarding flow itself (call order, people rules, validate, submit, enablement) → `payabli-boarding`
- OAuth2 setup and error handling → `payabli-fundamentals`
- Sandbox test data → `payabli-testing`
