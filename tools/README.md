# Tools

Reference tooling for the Meta-Universe specification. These are minimal
reference implementations meant to make the spec verifiable, not a product. The
specification refers to them by **logical command name** (`mu-fingerprint`,
`mu-validate`, …); this folder is the current implementation.

| Command | File | Purpose |
|---------|------|---------|
| `mu-fingerprint` | `mu-fingerprint.ps1` | Reference implementation of the **Semantic Fingerprint** canonicalization defined in [MMAS-Interchange](../02-architecture/MMAS-Interchange.md). |
| `mu-validate` | `mu-validate.ps1` | Reference MUIF validator: runs the machine-checkable Abstract Test Procedures (V0–V2) and emits a [Validation Report](../schemas/validation-report.schema.json). Exit 0 if no Error. |
| `mu-requirements` | `mu-requirements.ps1` | Regenerates [`REQUIREMENTS-INDEX.md`](../REQUIREMENTS-INDEX.md) from the Normative documents. |
| `mu-spec-index` | `mu-spec-index.ps1` | Regenerates [`spec-index.yaml`](../spec-index.yaml), the machine-readable index of every document. |
| `mu-test` | `../tests/run-tests.ps1` | Runs the Semantic Test Kit. |

## Implementation note

The reference tools are currently implemented in **PowerShell Core (`pwsh`)**,
which runs on Windows, macOS and Linux. They were chosen because the spec is
authored without a Node/Python toolchain assumption. A **language-neutral CLI**
(`mu-*`, plus `mu-diff`) is on the [roadmap](../MATURATION-ROADMAP.md); the
logical command names above are stable, so documents and CI do not depend on the
implementation language.

## Invoking

```text
# logical command                         # current implementation
mu-fingerprint <file>                      pwsh tools/mu-fingerprint.ps1 <file>
mu-validate    <file>                      pwsh tools/mu-validate.ps1 <file>
mu-test                                    pwsh tests/run-tests.ps1
```

Example:

```text
mu-fingerprint examples/minimal-person/person.muif.json
# sha256:a628b2afb96dc673f7e2f9161569e573fc70892d10a6997fad7aaa14b04a639d
```
