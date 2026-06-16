# Multi-Cloud Infrastructure as Code — Reference Patterns

> A **sanitized, representative** slice of production infrastructure I designed and
> operate: Terraform modules, Ansible roles, and CI/CD patterns for a multi-cloud
> platform (Alibaba Cloud · AWS · GCP).
>
> This is a **portfolio repository**. It contains no real credentials, IPs,
> account IDs, or hostnames — every environment-specific value is a variable with
> an `.example` placeholder. The goal is to show *how* I structure infrastructure,
> not to be runnable against any live account.

## Why this repo exists

I run the platform for a digital product company as a single platform engineer.
The full estate is private; this repo extracts the *patterns* worth showing:

- **DRY Terraform** — serverless apps defined once and fanned out with `for_each`
  instead of copy-pasted resources.
- **Secrets that never touch git** — sensitive fields kept out of `.tf` via
  `lifecycle.ignore_changes`, managed by the deploy pipeline / Vault.
- **Idempotent Ansible** — a reusable role that pulls a compose stack, injects
  managed secrets, and converges it.
- **Cost-aware automation** — a scheduled job that parks non-production
  environments outside working hours.

## What's inside

```
.
├── terraform/
│   └── alibaba/
│       └── sae/                 # Serverless apps via for_each (DRY)
│           ├── main.tf
│           ├── variables.tf
│           ├── outputs.tf
│           ├── providers.tf
│           └── terraform.tfvars.example
├── ansible/
│   └── roles/
│       └── compose_stack/       # Idempotent self-hosted stack deploy
│           ├── tasks/main.yml
│           ├── defaults/main.yml
│           └── README.md
├── .github/
│   └── workflows/
│       └── power-scheduler.yml   # Park dev/UAT off-hours to cut cost
├── docs/
│   └── architecture.md           # Diagrams (Mermaid)
├── .gitignore
└── LICENSE
```

## Case studies

The reasoning and impact behind these patterns are written up in
[`case-studies/`](./case-studies/):

- [Load-balancer consolidation](./case-studies/01-cost-optimization-clb-consolidation.md) — 9 LBs → 2 Ingress, ~75% cost cut
- [Multi-cloud IaC platform](./case-studies/02-multi-cloud-iac-platform.md) — 3 clouds, one workflow
- [Serverless outage postmortem](./case-studies/03-incident-postmortem-sae-outage.md) — audit-log root-cause + guardrails
- [Hybrid-cloud observability](./case-studies/04-observability-fleet-monitoring.md) — one Grafana across Alibaba + AWS
- [Architecture diagrams](./case-studies/diagrams.md) · [LinkedIn / web copy](./case-studies/linkedin-and-web-copy.md)

## A note on safety

If you're building something similar: the single most important habit here is
that **`terraform.tfstate`, `*.tfvars`, and `.env` are gitignored and never
committed** — managed secrets live in Vault or pipeline variables. See
[`.gitignore`](./.gitignore).

## License

[MIT](./LICENSE) — patterns are free to reuse.
