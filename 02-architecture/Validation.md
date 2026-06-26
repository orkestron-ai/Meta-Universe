# Validation

**Meta-Universe Specification**

**Document ID:** MU-V2-ARCH-006  
**Title:** Validation — Levels of Semantic Verification  
**Document Class:** Normative  
**Version:** 2.0 (Draft)  
**Status:** Working Draft  
**Normative References:** MUC, [MMAS-Core](../02-architecture/MMAS-Core.md), [MMAS-Conformance](../02-architecture/MMAS-Conformance.md)  
**Informative References:** [Certification](../06-ecosystem/Certification.md), [Compatibility-Matrix](../06-ecosystem/Compatibility-Matrix.md)  
**Copyright:** © Orkestron.AI  
**License:** Apache-2.0

---

# 1. Purpose

This document defines **Validation** within the Meta-Model Architecture Standard (MMAS).

Validation is the process of verifying that a meta-model is well-formed, internally consistent, constitutionally compliant and ready to participate in federation. It is the bridge between an architectural specification and a trustworthy semantic model.

---

# 2. Scope

This document applies to:

- the validation of a single meta-model and its artifacts;
- the validation of imported external standards;
- the role of validation across the meta-model lifecycle;
- the relationship between validation and [Conformance](../02-architecture/MMAS-Conformance.md) and [Certification](../06-ecosystem/Certification.md).

It does not mandate a specific validation tool or implementation.

---

# 3. Principles

- **Validation is layered.** Different concerns are verified at different levels.
- **Validation is continuous.** A model is validated throughout its lifecycle, not once.
- **Validation is explainable.** Every result identifies what was checked and why it passed or failed.
- **Validation is technology-independent.** It verifies semantics, not storage or transport.

---

# 4. Dimensions of Validation

Validation answers four progressively deeper questions:

1. Is the model **well-formed**? (syntax and structure)
2. Is the model **internally consistent**? (semantics)
3. Does the model **obey the Constitution**? (constitutional compliance)
4. Can the model **participate in federation**? (interoperability)

These questions map onto the validation levels below.

---

# 5. Validation Levels

The Meta-Universe defines a layered validation model. Each level assumes the levels below it have passed.

| Level | Name | Verifies |
|-------|------|----------|
| **V0** | Syntax | The artifacts are syntactically valid and parseable. |
| **V1** | Structural | The model conforms to the MMAS composition hierarchy (Meta-Model → Bundles → Layers → Objects → Properties / Relationships / Events / Contracts / Projections → Manifest). |
| **V2** | Semantic | The model is internally consistent: identities are unique, references resolve, relationships are well-typed, naming is canonical. |
| **V3** | Constitutional | The model preserves every applicable [Constitutional](../01-constitution/Meta-Universe-Constitution.md) article (identity, provenance, traceability, projection separation, context). |
| **V4** | Federation | The model can participate in federation: it exposes public schemas, declares Semantic Contracts, supports Projection exchange and version negotiation. |
| **V5** | Runtime *(optional)* | The model's live instances remain consistent with the model, and observed reality does not contradict declared semantics. |

V0–V3 are **mandatory** for any MMAS-conformant model. V4 is required for any model that participates in [federation](../03-federation/MUFP.md). V5 is OPTIONAL and applies to running implementations.

---

# 6. Severity Classification

A validation result SHALL classify each finding by severity:

- **Error** — a violation that prevents conformance at the relevant level.
- **Warning** — a concern that does not block conformance but SHOULD be addressed.
- **Info** — an observation or recommendation.

A model passes a level only when no **Error** remains unresolved at that level.

---

# 7. Validation Report

A validation run SHALL produce a **Validation Report** that includes:

- the model identity and version (with its [Semantic Fingerprint](../02-architecture/Versioning.md));
- the highest validation level achieved;
- every finding, with severity, location and explanation;
- the validator identity and the validation timestamp.

The report is itself a traceable artifact and MAY be referenced by a [Conformance Statement](../02-architecture/MMAS-Conformance.md) or a [Certificate](../06-ecosystem/Certification.md).

---

# 8. Validation of Imported Standards

When a meta-model imports an external standard as a [Semantic Package](../02-architecture/Extension-Model.md), the imported package SHALL be validated:

- its declared namespaces and selected objects resolve;
- local extensions do not modify the imported model in prohibited ways;
- semantic mappings are well-formed;
- the imported version falls within the declared compatible range.

---

# 9. Continuous Validation

Validation SHALL be applied across the meta-model lifecycle:

- on creation, before publication;
- on every change, as part of the [Change Process](../01-constitution/Change-Process.md);
- on import of an external standard or another model;
- before establishing or amending a [federation](../03-federation/Federation-Lifecycle.md).

A change that lowers a model's achieved validation level SHALL be treated as a significant change under the Change Process.

---

# 10. Relationship to Conformance and Certification

Validation, Conformance and Certification are distinct:

- **Validation** verifies the model against the levels defined here.
- **[Conformance](../02-architecture/MMAS-Conformance.md)** declares which standards and maturity levels the model claims (in particular, MMAS level **A4 Validated** requires passing V0–V3, and V4 where federation applies).
- **[Certification](../06-ecosystem/Certification.md)** is independent confirmation of those claims.

---

# 11. Architectural Invariants

- Validation SHALL be layered (V0 through V5).
- A higher level SHALL assume the lower levels have passed.
- A model SHALL NOT claim a validation level it has not achieved.
- Every validation result SHALL be explainable and traceable.

---

# Future Directions

The validation model defined here verifies a single meta-model. Several broader forms of verification are anticipated and would form a dedicated **Semantic Validation Framework (SVF)**:

- **Cross-Model Validation** — consistency across several meta-models (e.g. Employee MM ↔ Department MM ↔ Project MM).
- **Cross-Universe Validation** — consistency of a federation between independent Universes.
- **Runtime Drift Detection** — divergence between a declared model and the real state of the world.
- **AI Reasoning Validation** — verification that an AI agent's conclusions do not contradict the constraints and semantics of the model.

These extend beyond base MMAS validation and are recorded here as candidate future standards (see [Roadmap](../06-ecosystem/Roadmap.md)).

---

# Final Statement

> Validation is how a meta-model earns trust: not by assertion, but by passing, level after level, the checks that prove it is well-formed, consistent, lawful and ready to federate.
