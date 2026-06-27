# Semantic Test Kit

Reproducible conformance tests for the MUIF validator. Each fixture is a small
MUIF document with a declared expectation; the runner asserts that valid fixtures
pass and that each invalid fixture fails on the **specific Abstract Test
Procedure** ([Validation](../02-architecture/Validation.md)) it is designed to break.

## Run

```text
mu-test
# ALL 7 TESTS PASSED
```

`mu-test` is the logical command for the Semantic Test Kit; see [`../tools/`](../tools/)
for how the reference tools are invoked.

## Fixtures

| Fixture | Expectation |
|---------|-------------|
| `valid/minimal.json` | passes (no self-declared fingerprint) |
| `valid/with-fingerprint.json` | passes; `V2-05` confirms the declared fingerprint |
| `invalid/bad-version.json` | fails `V0-02` (wrong `muif.version`) |
| `invalid/missing-provenance.json` | fails `V1-02` (Object missing `provenance`) |
| `invalid/duplicate-id.json` | fails `V2-01` (duplicate `id`) |
| `invalid/bad-csn.json` | fails `V2-03` (CSN violates the grammar) |
| `invalid/wrong-fingerprint.json` | fails `V2-05` (declared ≠ computed fingerprint) |

`golden/with-fingerprint.report.json` is the expected [Validation Report](../schemas/validation-report.schema.json)
for the `with-fingerprint` fixture, for reference and regression.

## Coverage

The kit exercises the structurally-checkable levels (V0–V2). Full JSON Schema
validation (V1-01) and the constitutional/federation levels (V3–V4) are added in
CI and as the kit grows (roadmap WS6 continuation).
