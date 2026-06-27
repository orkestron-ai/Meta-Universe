# Example: Minimal Person Meta-Model (MUIF)

A tiny but complete [MUIF](../../02-architecture/MMAS-Interchange.md) meta-model
that exercises all five primitives — Object, Relationship, Event, Contract,
Projection — plus the manifest and conformance declaration.

## Files

| File | Purpose |
|------|---------|
| `person.muif.json` | The model in canonical authoring form |
| `person.variant.json` | The **same model**, but with reordered keys, reordered set-arrays, extra non-semantic fields (`displayName`, `description`, a placeholder `fingerprint`, a different `assertionTime`, an `_note` key) |
| `FINGERPRINT` | The expected Semantic Fingerprint |

## What this example proves

Both files describe the identical model and therefore **MUST** produce the same
Semantic Fingerprint. This demonstrates that the fingerprint is
*serialization-independent*: it depends only on semantic content, not on key
order, whitespace, set-array order, or non-semantic metadata.

```text
mu-fingerprint person.muif.json
mu-fingerprint person.variant.json
# both print:
# sha256:a628b2afb96dc673f7e2f9161569e573fc70892d10a6997fad7aaa14b04a639d
```

## Schema validation

```bash
npx ajv-cli validate -s ../../schemas/manifest.schema.json \
  -r "../../schemas/*.schema.json" -d person.muif.json --spec=draft2020
```
