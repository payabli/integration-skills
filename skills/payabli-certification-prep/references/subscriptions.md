# Subscription certification recipes

Self-serve, but execution is time-based. Flows are in `payabli-subscriptions`.

- **Create:** create a subscription with valid schedule data → expect success.
- **Invalid schedule:** create with a bad schedule (for example a start date that isn't allowed) → expect rejection.
- **Update / delete:** modify and remove a subscription → expect success.
- **Execution:** schedule a near-term run and **wait** for the autopay to fire (no Payabli-side trigger needed), then confirm the resulting charge.
