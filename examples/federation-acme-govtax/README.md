# Golden Example: Acme HR ⇄ Government Tax federate over a Person

This is the **end-to-end golden example**. Two sovereign universes — **Acme**
(an employer) and **Government Tax** — federate so that an employee's details can
be used to file tax, without either side surrendering ownership of its model or
its data. You can follow a single person all the way through:

> **Identity → Mapping → Contract → Projection → Synchronization → Conflict.**

Everything here is concrete and machine-checked: the meta-models carry real
Semantic Fingerprints, the federation is a real [MUFP](../../03-federation/MUFP-Messages.md)
transcript, and both models pass validation V0–V4.

## The two universes

| | Acme | Government Tax |
|--|------|----------------|
| Meta-model | [`acme/employee-mm.muif.json`](acme/employee-mm.muif.json) | [`gov/taxpayer-mm.muif.json`](gov/taxpayer-mm.muif.json) |
| Object | `employee.person` | `taxpayer.taxpayer` |
| Names | `givenName`, `familyName` | `forename`, `surname` |
| Fingerprint | `sha256:0b4965f1…38c40` | `sha256:d51f639e…37ba6` |
| Validation | [report](acme/validation-report.json) (V4) | [report](gov/validation-report.json) (V4) |

The two models describe the same reality with **different vocabularies** — which
is exactly what federation must bridge.

## Follow the thread

1. **Identity** — the same human is `employee:12345` in Acme and `taxpayer:99821`
   in Government Tax. They are bound to one Canonical Identity by
   [`identity-binding.json`](identity-binding.json), matched on the shared tax id.
2. **Mapping** — the vocabularies are aligned by
   [`mapping/acme-to-gov.mapping.json`](mapping/acme-to-gov.mapping.json):
   `employee.familyName ≡ taxpayer.surname`, etc. The mapping pins the fingerprints
   of both sides, so it is only valid for these exact model versions.
3. **Contract** — disclosure is governed by [`contract.json`](contract.json)
   (`Federation`, purpose `tax-filing`, three permitted fields, purpose-bound,
   no onward disclosure). Fingerprint `sha256:44582ad8…28af0`.
4. **Projection** — Acme never sends the object; it sends a purpose-specific
   Projection exposing only the three contracted fields.
5. **Synchronization & Conflict** — Government Tax detects that Acme's
   `familyName = "Smith"` disagrees with its record `surname = "Smyth"`. Per
   [Conflict Preservation](../../03-federation/Conflict-Resolution.md), the
   conflict is recorded as a first-class `Conflict` Event, resolved to the
   authoritative value, and **the conflict event is kept in history** (the
   resolution Event references it via `causality`).

The whole exchange is in [`transcript.json`](transcript.json) — 17 MUFP
envelopes. As always, the first knowledge (the Projection) moves only at message
14, after identity, trust, contract and schema are settled.

## Verify

```bash
# fingerprints round-trip
pwsh ../../tools/mu-fingerprint.ps1 acme/employee-mm.muif.json   # sha256:0b4965f1...
pwsh ../../tools/mu-fingerprint.ps1 gov/taxpayer-mm.muif.json    # sha256:d51f639e...

# models validate against the MUIF schemas
npx ajv-cli validate -s ../../schemas/manifest.schema.json -r "../../schemas/*.schema.json" \
  -d acme/employee-mm.muif.json --spec=draft2020

# every envelope validates against the MUFP envelope schema
npx ajv-cli validate -s ../../schemas/mufp-envelope.schema.json -r "../../schemas/*.schema.json" \
  -d transcript.json --spec=draft2020
```
