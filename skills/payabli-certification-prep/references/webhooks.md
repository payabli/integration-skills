# Webhook certification recipes

Flows are in `payabli-webhooks`.

- **Step 0 — make your endpoint reachable (do this first):** the recipes below only work once Payabli can POST to you. Expose your handler with a tunnel for local dev (see `payabli-webhooks` → Local development) and create the notification subscription for the event. Until the endpoint is public and subscribed, nothing fires.
- **Delivery + ack:** run a sale → the `ApprovedPayment` webhook fires at your endpoint; return HTTP 200 to acknowledge.
- **Failure / retry:** don't return 200 on a delivery → expect Payabli to retry.
- **Chargeback / return events** *(needs a Payabli-side trigger)*: these don't fire on their own in sandbox — ask the Payabli team to trigger them, or raise it on the cert call.
