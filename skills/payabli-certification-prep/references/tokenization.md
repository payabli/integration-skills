# Stored-method certification recipes

Run each in sandbox and record results. Flows are in `payabli-tokenization`.

- **Save a method:** tokenize a card or bank account → returns a stored-method id.
- **Charge a stored method:** run a sale using the stored-method id → expect approval.
- **Token not found:** charge with a bogus stored-method id → expect the not-found error (`7007`).
- **Method mismatch:** charge a card stored-method while forcing a different method type → expect the mismatch error (`7004`).
