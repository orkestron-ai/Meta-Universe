# Contributing to Meta-Universe

Thank you for helping build an open standard. Contributions of all kinds —
issues, reviews, proposals, examples, tooling — are welcome.

## Before you start

1. Read the [Principles](00-foundation/Principles.md) and the
   [Constitution](01-constitution/Meta-Universe-Constitution.md). Every change
   must remain consistent with both.
2. Skim [STATUS.md](STATUS.md) and the [Governance](GOVERNANCE.md) model.

## How changes work

All changes flow through the [Change Process](01-constitution/Change-Process.md)
as a **Change Request (CR)** — a pull request that states:

- **Type:** Editorial · Corrective · Evolutionary · Breaking (plus the
  [Semantic Change Classification](01-constitution/Change-Process.md) where it
  applies).
- **Affected requirement IDs** (from [REQUIREMENTS-INDEX.md](REQUIREMENTS-INDEX.md)).
- **Compatibility impact** and, for breaking changes, migration guidance.

A CR to a Normative document is reviewed by the owning body (see
[GOVERNANCE.md](GOVERNANCE.md)) and goes through a public review period.

## Authoring rules

- **English only.** Match the calm, RFC/ISO register of the surrounding text.
- Use the **Standard Header** (see any existing document) and flat `#` section
  headings.
- Use RFC 2119 keywords (`SHALL`/`SHOULD`/`MAY`) **only** in Normative documents.
- Keep all JSON valid and all examples machine-checkable.

## Before you open a PR

Run the local checks with the reference tools (see [`tools/`](tools/) and
[`tests/`](tests/) for how to invoke them):

- **`mu-test`** — the Semantic Test Kit must pass.
- **`mu-requirements`** — regenerate `REQUIREMENTS-INDEX.md` if you changed normative text.
- **`mu-spec-index`** — regenerate `spec-index.yaml` if you added or renamed a document.

If you changed a model, confirm its fingerprint with **`mu-fingerprint <file>`**
and validate it with **`mu-validate <file>`**.

## Developer Certificate of Origin

By submitting a contribution you certify that you wrote it (or have the right to
submit it) and that it may be distributed under the project's
[Apache-2.0](LICENSE) license, including its patent grant.

## Reporting security issues

Do **not** open a public issue for vulnerabilities. See [SECURITY.md](SECURITY.md).

## Conduct

All participation is governed by the [Code of Conduct](CODE_OF_CONDUCT.md).
