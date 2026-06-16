# Security

This repository ships **Agent Skills** — Markdown instructions that guide a coding agent through a Payabli integration. It is not a running service, so "security" here is about the guidance and what it points at.

## What counts as a security issue here

- A skill that could steer an agent toward unsafe code — for example, leaking secrets, logging cardholder data, or skipping signature/verification steps.
- A malicious, hijacked, or typosquatted link or tool reference in a skill or doc.
- A supply-chain concern in tooling this repo references or runs.

## Reporting

Report privately — don't open a public issue for a suspected vulnerability.

- Use GitHub's **private vulnerability reporting**: the **Security** tab → **Report a vulnerability**. This stays confidential between you and the maintainers.

Please include the affected skill or file, what an agent might do as a result, and a minimal repro. **Never paste secrets** (API keys, tokens, cardholder data) into a report.

## Out of scope for this repo

- **Vulnerabilities in the Payabli platform or API** (not this repo) go through Payabli's vulnerability disclosure process: https://docs.payabli.com/vulnerability-disclosure
- **Integration or account problems** aren't security reports — contact your Payabli integration contact.
