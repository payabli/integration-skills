# Customer identifiers

Every call that touches a customer (creating one, charging, invoicing) must include at least one of the paypoint's **configured identifier fields**.

- Identifiers are configured in the **Payabli Portal** under **Settings → Custom Fields** and cascade from org to paypoints. Common choices: `email`, `customerNumber`, or a custom field like `clientId`.
- If none are configured, Payabli falls back to matching on `customerId`.
- A missing or unexpected identifier returns an opaque error like `Invalid customer identifiers: email`. Confirm which identifier the paypoint expects before building customer calls.

## Discover the configured identifiers from the API

Rather than asking the partner to look in the Payabli Portal, read the config:

- `GET /Paypoint/settings/{entry}` — the paypoint's configured custom fields and identifiers. https://docs.payabli.com/developers/api-reference/paypoint/get-paypoint-settings.md
- `GET /Organization/settings/{orgId}` — org-level defaults that cascade to paypoints. https://docs.payabli.com/developers/api-reference/organization/get-organization-settings.md

More on customers: https://docs.payabli.com/guides/pay-ops-developer-customers-manage.md
