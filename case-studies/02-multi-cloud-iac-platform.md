# Multi-Cloud Infrastructure as Code Platform

**Theme:** Infrastructure as Code · Platform Engineering
**Stack:** Terraform, Ansible, HashiCorp Vault, Docker Compose, GitLab CI, GitHub Actions

---

## Context

A digital product company ran production workloads spread across **three cloud
providers** — Alibaba Cloud (primary), AWS, and GCP — plus a fleet of
self-hosted developer tooling. Much of it had grown organically: resources
created by hand in consoles, undocumented, with no single source of truth for
"what exists and why."

## Problem

Console-created infrastructure doesn't scale with one platform engineer:

- No reproducibility — you can't recreate or audit what you can't describe.
- No change review — risky edits happened live, in the console.
- Secrets scattered across service configs with no consistent handling.
- Drift between "what we think is running" and "what's actually billed."

## Approach

I brought the estate under **codified, reviewable infrastructure**:

**Terraform (~320 modules)** organized by provider and project. I imported
existing live resources (managed databases, load balancers, serverless apps)
into Terraform state rather than recreating them — so the code reflected reality
without a risky teardown.

**Secret handling done deliberately.** Sensitive fields (DB passwords, JWT
secrets, service-account keys, object-storage credentials) are kept *out* of the
`.tf` files entirely and managed via `lifecycle { ignore_changes = [...] }`, so
secrets live only in gitignored state — never in version control. For
configuration-time secrets, Ansible integrates with **HashiCorp Vault**
(init / unseal / read / write roles).

**Ansible** handles everything above the cloud API line: server configuration,
the self-hosted Docker Compose stack, and node-level agents — with roles and
playbooks split by lifecycle (install / configure / deploy / update / uninstall).

**CI/CD across two platforms.** Code lives on GitLab (self-hosted) but mirrors to
GitHub via GitHub Actions, which also runs scheduled platform jobs — e.g. a
serverless "power scheduler" that stops dev/UAT apps outside working hours to
cut cost.

## Architecture

```
                         ┌──────────────────────────┐
                         │   Git (GitLab ⇄ GitHub)   │  source of truth + CI
                         └─────────────┬─────────────┘
              ┌────────────────────────┼────────────────────────┐
              ▼                        ▼                         ▼
        ┌──────────┐            ┌────────────┐            ┌─────────────┐
        │ Terraform│            │  Ansible   │            │   Docker    │
        │  (~320   │            │ + Vault    │            │  Compose    │
        │  modules)│            │  (config)  │            │ (self-host) │
        └────┬─────┘            └─────┬──────┘            └──────┬──────┘
   ┌─────────┼─────────┐              │                          │
   ▼         ▼         ▼              ▼                          ▼
Alibaba     AWS       GCP        servers / agents        GitLab, Vault,
(primary)                                                SonarQube, Wiki, …
```

## Impact

- **Three clouds under one reviewable workflow** — every change is a diff, not a
  console click.
- **Imported live infrastructure into Terraform** without downtime, eliminating
  drift between billed reality and described state.
- **Secrets never enter version control** — a deliberate state-only +
  Vault pattern.
- **Decommissioned an entire cloud provider** (migrated all workloads off a
  fourth provider and archived its artifacts) once everything was codified and
  comparable.

## What I'd highlight in an interview

- The decision to *import* rather than *recreate* — pragmatic IaC adoption on a
  running system.
- Treating secret management as a first-class design constraint, not an
  afterthought.
- Running a coherent platform across three providers as a single engineer by
  leaning on automation and convention.

## Skills demonstrated

`Terraform` · `Ansible` · `HashiCorp Vault` · `multi-cloud` ·
`GitLab CI` · `GitHub Actions` · `Docker Compose` · `secret management` ·
`infrastructure migration`
