# Pay Out certification recipes

Run each in sandbox and record results. Flows are in `payabli-send-payments` and `payabli-bills`. The payment method (vCard, ACH, check) is the vendor's; for testing, exercise each one you support.

- **Authorize + capture:** authorize a payout, then capture → expect approval at each step.
- **Auto-capture:** authorize with `autoCapture: true` → confirm capture via the payout capture webhook.
- **Reissue:** reissue a payout with a different method → expect a new, linked payout.
- **Cancel before processed:** cancel an authorized, uncaptured payout → expect success.
- **Cancel after settled** *(needs a Payabli-side trigger)*: reaching settled needs a funding trigger; a post-settlement cancel should be **rejected**.
- **Vendors:** create, update, and delete a vendor → expect success.
- **Bills:** create a bill and pay it through a payout → expect success.
