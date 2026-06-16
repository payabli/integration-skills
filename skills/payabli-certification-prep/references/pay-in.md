# Pay In certification recipes

Run each in sandbox and record the reference ID and result. Use Payabli's published test cards and bank data (see `payabli-testing`); flows and field shapes are in `payabli-accept-payments`. Expected values below are the standardized v2 response codes — the exact decline/error code can vary by processor (see Processor & transient behavior at the end).

## Card

- **Sale (approval):** charge a small amount with an approval test card → approved (`A0000`).
- **Decline:** charge with the decline test card → a decline, not an error (`D0100`, generic decline).
- **CVV mismatch:** charge a valid card with an incorrect CVV (values in `payabli-testing`) → expect a CVV-mismatch decline. On some connectors a bad CVV returns `E9999` ("unexpected error") instead of a clean decline — if so, capture it and raise it on the cert call (see below). AVS (address/ZIP) mismatch has no published self-serve test value; cover it on the cert call rather than rehearsing it.

## Embedded component

- Process a payment with the EmbeddedMethod UI (`PayabliExec('pay')`) → approved (`A0000`).
- Tokenize a method (`PayabliExec('method')`) → returns a stored-method id.
- Decline, then re-initialize (`PayabliExec('reinit')`) → the component resets for another attempt.

## ACH

- **Sale:** charge with valid test bank data → accepted.
- **Validation failure:** ACH decline/validation testing is **not self-serve** — there's no published failure test account. Raise it on the cert call.

## Auth / capture / void

- Authorize, then capture → approved at each step (`A0000`).
- Authorize, then void before settlement → success (`A0003`, canceled).

## Refund

- A *successful* refund needs a **settled** transaction, and reaching settled/funded requires a Payabli-side funding trigger — flag this for the cert call.
- Self-serve negative checks: a refund above the original amount, or before settlement, should be **rejected** (`E7002`, invalid transaction state).

## Processor & transient behavior

- **AVS/CVV handling varies by processor.** v2 response codes are standardized, but a clean AVS/CVV decline on one connector can surface as `E9999` ("unexpected error") on another. If you get an unexpected error instead of the expected decline, capture it and raise it on the cert call — don't treat the recipe as failed.
- **Transient device errors.** Sandbox occasionally returns `D0583` ("device error") on a card sale that clears on retry. Retry once before concluding a recipe failed.
