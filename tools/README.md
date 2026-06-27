# Tools

Reference tooling for the Meta-Universe specification. These are minimal
reference implementations meant to make the spec verifiable, not a product.

| Tool | Purpose |
|------|---------|
| `mu-fingerprint.ps1` | Reference implementation of the **Semantic Fingerprint** canonicalization defined in [MMAS-Interchange](../02-architecture/MMAS-Interchange.md). |

## mu-fingerprint

Computes the serialization-independent Semantic Fingerprint of a MUIF document.

```bash
pwsh tools/mu-fingerprint.ps1 examples/minimal-person/person.muif.json
# sha256:a628b2afb96dc673f7e2f9161569e573fc70892d10a6997fad7aaa14b04a639d

# -ShowCanonical prints the canonical JSON to stderr for debugging
pwsh tools/mu-fingerprint.ps1 path/to/model.json -ShowCanonical
```

Roadmap (see [../MATURATION-ROADMAP.md](../MATURATION-ROADMAP.md)) — the
cross-platform CLI **WS13** will add `mu-validate` and `mu-diff` and a
language-neutral implementation; this PowerShell script is the WS1 reference.
