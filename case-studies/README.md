# Platform & Cloud Infrastructure — Portfolio Case Studies

> Sanitized write-ups of production infrastructure work I led on a multi-cloud
> platform (Alibaba Cloud, AWS, GCP). Company names, public IPs, resource IDs,
> and domains have been replaced with placeholders; architecture decisions and
> impact metrics are real.

I own the end-to-end platform for a digital product company running AI-powered
creative SaaS products — from Terraform-managed cloud resources and Ansible
configuration to CI/CD, observability, cost governance, and incident response.

## Role at a glance

**Platform / DevOps / SRE** — single-person platform function supporting
multiple product teams across three cloud providers.

- **IaC:** Terraform (~320 modules across Alibaba, AWS, GCP), Ansible (roles,
  playbooks, HashiCorp Vault integration)
- **Compute:** Alibaba SAE (serverless app engine), ECS, Docker Compose
- **Networking:** VPC design, CLB / SAE Ingress (host-based L7 routing),
  Cloudflare
- **CI/CD:** GitLab CI, GitHub Actions (cross-platform mirroring, scheduled jobs)
- **Observability:** Prometheus, Grafana, Loki, node_exporter; cloud-native
  metrics exporters (CloudMonitor, CloudWatch, GCP billing)
- **Self-hosted platform:** GitLab, SonarQube, Vault, Wiki.js, OpenProject

## Case studies

| # | Case study | Theme | Headline result |
|---|-----------|-------|-----------------|
| 1 | [Cloud cost optimization: load-balancer consolidation](./01-cost-optimization-clb-consolidation.md) | FinOps / networking | **9 load balancers → 2 Ingress, ~75% cost cut** |
| 2 | [Multi-cloud Infrastructure as Code platform](./02-multi-cloud-iac-platform.md) | IaC / platform | 3 clouds under one Terraform + Ansible workflow |
| 3 | [Incident postmortem: serverless production outage](./03-incident-postmortem-sae-outage.md) | SRE / incident response | Root-caused a full-fleet 503 in hours via audit-log forensics |
| 4 | [Centralized observability for a hybrid-cloud fleet](./04-observability-fleet-monitoring.md) | Observability | One Grafana pane of glass across Alibaba + AWS |

**Visuals:** [Architecture diagrams](./diagrams.md) (Mermaid — render natively on GitHub, or export PNG/SVG for a personal site).

**Ready-to-post copy:** [LinkedIn & personal-site copy](./linkedin-and-web-copy.md) — headline, About, experience bullets, project cards, sample post.

**The code:** see the [repository root](../) for the sanitized Terraform, Ansible, and CI/CD patterns these case studies describe.

## How to use these for LinkedIn / a personal site

- **Personal website:** publish each case study as its own page. The
  Problem → Approach → Impact structure reads well and is skimmable.
- **LinkedIn "About" / Experience:** lift the **Impact** bullets — they are
  quantified and outcome-focused (cost saved, RAM freed, MTTR).
- **Interviews:** each file maps cleanly to a STAR answer
  (Situation, Task, Action, Result).
- **Do not** publish the raw infrastructure repository. These sanitized
  write-ups exist precisely so the *work* can be shown without exposing a
  former/current employer's internal topology. If you want to name the company,
  get a quick OK from them first.
