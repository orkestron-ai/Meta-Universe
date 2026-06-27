# Example: MUFP Federation Handshake

A worked transcript of the [MUFP](../../03-federation/MUFP.md) canonical sequence
realized as concrete [MUFP envelopes](../../03-federation/MUFP-Messages.md).

`transcript.json` is an ordered array of envelopes for the scenario *Acme
(employer) federates with Government Tax to file an employee's tax return*. It
walks the state machine `INIT → DISCOVERED → NEGOTIATED → TRUSTED → CONTRACTED →
ACTIVE`, and — per the core MUFP guarantee — the first knowledge (a Projection)
moves only at the **last** message, after purpose, trust and contract are settled.

## Messages in order

| # | Type | State after |
|---|------|-------------|
| 1–2 | `Hello` / `HelloAck` | `DISCOVERED` |
| 3–4 | `CapabilityOffer` / `CapabilityAccept` | `NEGOTIATED` |
| 5–6 | `TrustRequest` / `TrustResponse` (with Trust Vector) | `TRUSTED` |
| 7–8 | `ContractProposal` / `ContractAccept` | `CONTRACTED` |
| 9–10 | `ProjectionRequest` / `ProjectionResponse` | `ACTIVE` |

> The full WS4 golden example adds the two complete meta-models, the Semantic
> Mapping, the Identity Binding and the validation reports for both universes.

## Validate

Each envelope validates against
[`../../schemas/mufp-envelope.schema.json`](../../schemas/mufp-envelope.schema.json):

```bash
npx ajv-cli validate -s ../../schemas/mufp-envelope.schema.json \
  -r "../../schemas/*.schema.json" -d transcript.json --spec=draft2020
```
