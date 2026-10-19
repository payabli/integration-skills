---
name: payabli-boarding
description: >-
  Use when onboarding merchants to Payabli through the API — creating the
  business, its people, paypoints, and bank accounts, opening a boarding
  application, validating and submitting it, answering underwriting
  requests, or tracking an application's status and enablement. Moving an
  existing integration off the legacy /Boarding/* endpoints lives in
  payabli-boarding-migration. Reads payabli-integration.md on load if
  present.
metadata:
  author: payabli
  version: "0.1"
---

# Payabli boarding

Board merchants with intelligent boarding, which uses the `/v2` businesses, people, paypoints, payment methods, and applications (`/v2/requests`) endpoints.

## If boarding calls fail unexpectedly

Intelligent boarding is an opt-in beta. If boarding calls return `400` or `500`-range errors that the response doesn't explain, such as on the first call, tell the developer to check with their Payabli contact that intelligent boarding is enabled for their account and that their API credentials have the right permissions. A `400` with field errors is a validation problem, not this.

## Load fundamentals first

If `payabli-fundamentals` is not already loaded, load it now, then continue.

## On load

If `payabli-integration.md` exists at the repo root, read it; honor its `## SDK` value.

## Authenticate with OAuth2 only

The boarding endpoints accept only an OAuth2 Bearer token. Use the OAuth2 flow from `payabli-fundamentals`. https://docs.payabli.com/developers/oauth-authentication.md

## Create separate records in order

Legacy boarding put everything in one application. Intelligent boarding splits it into records that reference each other by UUID. The application only requests services for a business that already exists. Read the model first: https://docs.payabli.com/guides/pay-ops-boarding-object-model-overview.md

Create the records in this order, because each needs a reference from the one before it:

1. **Business** — `POST /v2/businesses`. The create response names the reference `businessUuid`; it's the value every other call calls `businessReference`. Or skip this call and create the business inline in step 2. Fields and allowed values: https://docs.payabli.com/developers/api-reference/businesses/create-a-business.md
2. **Paypoint** — `POST /v2/paypoints`, with either `businessReference` or an inline `business` object (exactly one). `doingBusinessAs` lives here, not on the business; each location is its own paypoint on the same business. Fields and allowed values: https://docs.payabli.com/developers/api-reference/paypoints/create-a-paypoint.md
3. **People** — `POST /v2/people`, once per person, with a `businessRelationship` object that links them to the business. Fields and allowed values: https://docs.payabli.com/developers/api-reference/people/create-a-person.md
4. **Bank accounts** — `POST /v2/payment-methods` with a `data` array. Fields and allowed values: https://docs.payabli.com/developers/api-reference/payment-methods/create-payment-methods.md
5. **Application** — `POST /v2/requests` with the `businessReference` and a `services` object. Fields and allowed values: https://docs.payabli.com/developers/api-reference/applications/create-an-application.md
   Send `requestTemplate` on every application. The API accepts an application without one, but Payabli assigns the underwriting policy from the template, so a submitted application without one errors in review. The partner chooses the template. Before you create the application, ask the developer which template to use, unless they already named one. If you can't ask, stop before creating the application and report that you need a template. Never pick one from the template list yourself. https://docs.payabli.com/guides/pay-ops-developer-templates-manage.md
6. **Documents** — upload any documents the application requires. See "Upload required documents" below.
7. **Validate**, then **submit**. https://docs.payabli.com/developers/api-reference/applications/validate-an-application.md and https://docs.payabli.com/developers/api-reference/applications/submit-an-application.md

To have the merchant complete the application in Payabli's hosted boarding application instead, create it with the API and send them `https://app.payabli.com/boarding/app/{requestsReference}` (sandbox: `https://app-sandbox.payabli.com/boarding/app/{requestsReference}`). If the partner uses a custom domain for the hosted application, use that domain instead of Payabli's.

Follow the end-to-end walkthrough for request bodies: https://docs.payabli.com/guides/pay-ops-developer-boarding-new-entity-paypoint.md. For more services on an existing merchant, see https://docs.payabli.com/guides/pay-ops-developer-boarding-add-services.md; for another location, https://docs.payabli.com/guides/pay-ops-developer-boarding-new-location.md.

## Link every person as Owner or Employee

Set the role in `businessRelationship.personType`, and use only **`Owner`** and **`Employee`**. Validation holds every other role (`Contact`, `Director`, `Signer`, `AuthorizedUser`) to the owner requirements. The API also drops `ownershipPercentage` on non-owner links without an error, so those people can never pass. Link contacts and other non-owners as `Employee`.

On the business link, also set:

- `isPrimaryController: true` on at least one person.
- `isSigner: true` on exactly one **owner** — only an owner can sign. Setting it on one person clears it from the others.
- `ownershipPercentage` on every owner, totaling 100 or less, with at least one owner at 25% or more — unless the business's `legalStructure` is `government` or `non-profit`.

https://docs.payabli.com/guides/pay-ops-developer-people-manage.md

## Reuse people across businesses

A person is one record that can be linked to many businesses. The link holds the per-business role, title, ownership, and signer flag.

- **Search before you create.** `POST /v2/people/search` with the name (plus date of birth or email when you have them). Pass the **organization's** entry name in `entry` (`OrgEntryName` from `GET /Organization/read/{orgId}`; that response uses capitalized field names) and the org ID in `orgId`; both are required. A paypoint's entry name limits the search to that paypoint's business and misses owners of your other merchants. Reuse a match's `personReference` when its identity details agree. A result with `isFromVendor: true` has no `personReference`, so create that person. https://docs.payabli.com/developers/api-reference/search-people.md
- **Conflicting details mean stop.** If a match or two input rows disagree on identity (date of birth, address), ask the developer. Don't create a second record, and don't overwrite the existing one.
- **Link, don't recreate.** Attach an existing person with the business people endpoint. In a batch, create each unique person once and link them once per business. https://docs.payabli.com/developers/api-reference/businesses/link-a-person-to-a-business.md
- **Collect identity before you create.** You can't add or change `dateOfBirth`, `ssn`, or `nationalIdNumber` after the person exists, so a person created without them can't be fixed with a `PATCH`. Get them first. https://docs.payabli.com/guides/pay-ops-developer-people-manage.md
- **Check `warnings` on person create.** `LINK_OWNERSHIP_EXCEEDED` comes back with a `201`, but the person isn't linked.

## Make batch runs safe to rerun

Keep a ledger keyed by your own row ID. Store each reference as it's created (business, paypoint, people, payment methods, application) and the last completed step. On a rerun, skip completed steps and continue from the ledger. Don't rely on create calls to catch repeats: some reject a duplicate (a reused tax reference returns an error), but people don't. Hold a row with gaps instead of submitting it, and finish the rest.

## Bank accounts

Send each account as an item in the `data` array, with `type: bank_account`, `accountOwner` (the `businessReference`), and `ownerType: business`. `nickname` is required by validate and is your own label for the account, so set one even when the merchant didn't supply it. Each account's `usage` array says what it's for: `deposits` for funding, `billing` for the account Payabli debits for fees, `payOutFunding` for payouts. Between them the accounts need `deposits` and either `billing` or `refunds`. Don't use `withdrawals`.

Mark exactly one account `isDefault: true`. Sending `isDefault: true` on a later account moves the default to it. To check which account is the default, read the business (`GET /v2/businesses/{businessReference}`); a single payment-method read doesn't return `isDefault`. https://docs.payabli.com/guides/pay-ops-developer-payment-methods-manage.md

## Upload required documents

The template and Payabli's business rules decide which documents an application needs. For example, a business with an `annualRevenue` of $1,000,000 or more needs bank statements. Upload them through the API before you submit:

1. List what's needed: `GET /v2/requests/{requestsReference}/documents/requirements`. Each requirement gives the `fieldPath`, `subjectTypes`, `allowedFormats`, and `maxUploads`, and a person requirement carries that owner's `personReference`.
2. Upload each file: `POST /v2/requests/{requestsReference}/documents` as multipart form data, with `fieldPath`, `subject`, and `personReference` for a person requirement. Copy these values from the requirement; don't build them yourself.
3. To replace a file, delete it with its `documentReference`, then upload the new one.

Validate reports a required document as missing until it's uploaded. A `400 VALIDATION_ERROR` on upload means the file doesn't fit the requirement; read the `message`. Get real documents from the developer or the merchant; never generate placeholder files outside sandbox tests. https://docs.payabli.com/guides/pay-ops-developer-applications-manage.md#upload-documents

## Validate before every submit

`POST /v2/requests/{requestsReference}/validate` reports every missing or invalid field by its path on the record (for example `business.taxReference`). It doesn't change anything. Treat it as the source of truth for readiness:

- **Request services first.** Requirements depend on the requested services; with no services, validate checks the requirements for every service.
- **Fill gaps with real data, never inferred data.** When validate reports a missing field, get the value from the developer or the merchant. Don't derive it (formation state from an address, nationality from a country, `taxIdCountry` from the tax ID's format) or default it (100 for a percentage) just to pass validate. Invent values only for sandbox test data the developer asked for.
- **Validate is stricter than create.** A record can save without fields validate still requires, so a successful create doesn't mean the data is complete.
- **`business.processingMetrics.environments` means the sales channel split.** Validate can report this path, but no such field exists. Set `inboundPresentPercent`, `inboundOnlinePercent`, and `inboundMotoPercent` instead: at least one above 0, summing to 100.
- **Submit doesn't enforce every validate rule.** An application can submit with gaps validate would have caught, and then stall in review. Always validate, fix the **records** (business, people, bank accounts — not the application), and validate again until the result is valid.

For what validation checks on each record, see the Validate an application section of https://docs.payabli.com/guides/pay-ops-developer-applications-manage.md

## Submit

`POST /v2/requests/{requestsReference}/submit`, while the application is in `draft`. Send a `signer` object with the signature details: `signature` and `signatureType`, or `signedDocumentReference` if the signer signed in your own e-sign tool. Set `acceptance` and `pciAttestation` to `true` only when the signer actually accepted the terms and attested; Payabli records `false` when they're left out. To pick the signer on this call, send their `personReference` in `signer`. Payabli takes the signer's identity from their person record and business link, so fix those before you submit. It fails with `422 SIGNER_REQUIRED` if no owner is marked `isSigner`, and `422 SIGNER_NOT_OWNER` if the named signer isn't an owner. https://docs.payabli.com/guides/pay-ops-developer-applications-manage.md

## After submit

- Branch on the `applicationStatus` name, not the number, and check `allowedActions` before calling a lifecycle endpoint. https://docs.payabli.com/guides/pay-ops-boarding-application-status-reference.md
- Edit the application only in `draft`. After submit, fix data on the records, not the application.
- When underwriting asks for documents (`pendingdocuments`), upload them with the document endpoints first, then call `provide-documents`. When it asks a question (`pendingresponse`), answer it, then call `provide-response`. Neither call takes a body, and both return the application to review.
- Withdraw an application instead of deleting it, because there's no delete. Withdrawal is final.
- `GET /v2/requests/{requestsReference}/history` lists every transition and its cause.
- After approval, the application stays `approved` or `autoapproved` until every service is live, then becomes `activated`. Enablement sends no webhooks — poll `GET /v2/requests/{requestsReference}/enablement`, and when `blockedOn` is `merchant_data`, fix the fields it lists.

## Data formats that trip builds

- Dates are ISO 8601 (`2015-06-01`). US-style dates return `400`.
- Send `isForeignOwned` as `true` or `false` explicitly.
- `legalStructure` takes fixed values only. Check the business create reference for the list.
- Names are split: `firstName`, `lastName`, optional `middleName`.

## Boundaries

- Migrating from the legacy `/Boarding/*` endpoints → `payabli-boarding-migration`
- OAuth2 setup, environments, and error handling → `payabli-fundamentals`
- Sandbox test data → `payabli-testing`
