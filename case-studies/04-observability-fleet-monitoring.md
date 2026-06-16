# Centralized Observability for a Hybrid-Cloud Fleet

**Theme:** Observability · SRE · Capacity Management
**Stack:** Prometheus, Grafana, Loki, node_exporter, CloudMonitor / CloudWatch exporters

---

## Context

Workloads were spread across Alibaba Cloud and AWS, plus self-hosted services
(GitLab, build tooling, app servers). There was no single place to answer basic
operational questions: *Is that host out of RAM? Is this service up? Where did
last month's spend go?*

## Problem

Without a unified view:

- Capacity issues (e.g. a memory-starved CI server) were only noticed when
  something broke.
- Each cloud's native console was a separate silo — no cross-provider correlation.
- Cost and resource health lived in different tools than the ops team used daily.

## Approach

I stood up a **central Grafana + Prometheus + Loki stack** as a single pane of
glass for the whole fleet, deployed via Docker Compose and managed with Ansible.

**Deliberate scrape topology** to keep it secure and cheap:

- **Alibaba hosts** are scraped over **private VPC IPs** (monitoring server and
  targets share a VPC) — no traffic over the public internet, tight security
  groups (`node_exporter` reachable only from the monitor's private IP).
- **AWS hosts** are scraped over their public EIP, with security groups locked to
  the monitor's IP only.
- Cloud-native metrics (Alibaba CloudMonitor, AWS CloudWatch, GCP billing) flow in
  through dedicated exporters, so platform metrics and app metrics live together.

**Config as code in a dedicated repo**, pulled and deployed by an Ansible role —
not hand-edited on the box — so the monitoring stack itself is reproducible.

### Capacity win this enabled

With host metrics visible, I caught a **self-hosted GitLab server sitting at ~89%
RAM with no swap** — a latent OOM risk. I tuned it deliberately and reversibly:

- Added an **8 GiB swap file** as an OOM safety net (`swappiness` left at 0, so
  steady-state performance is unchanged — swap is purely a backstop).
- Right-sized the app server's worker processes (8 → 4 Puma workers) to match
  actual CPU load, which was near-idle despite the memory pressure.

**Result: RAM usage dropped from ~89% (14 GiB) to ~47% (7.1 GiB)**, with
available memory going from ~1.2 GiB to ~8.5 GiB — turning a fragile box into a
comfortable one, with a documented rollback path.

## Architecture

```
        ┌───────────────────────────────────────────────┐
        │   Central monitoring host (Grafana/Prom/Loki)  │
        │            monitoring.example.com              │
        └───────┬───────────────────────────┬───────────┘
                │ private VPC scrape         │ public EIP scrape (SG-locked)
        ┌───────▼────────┐           ┌───────▼────────┐        ┌──────────────┐
        │ Alibaba hosts  │           │   AWS hosts    │        │ cloud-native │
        │ node_exporter  │           │ node_exporter  │        │  exporters   │
        │ gitlab/app/... │           │                │        │ CW / CM / GCP│
        └────────────────┘           └────────────────┘        └──────────────┘
```

## Impact

- **One Grafana pane of glass** across Alibaba + AWS + self-hosted services.
- **Proactive capacity management:** found and fixed a near-OOM CI server before
  it failed — **RAM 89% → 47%**, reversibly.
- **Secure-by-design scraping:** private-VPC where possible, IP-locked security
  groups everywhere else.
- **Reproducible monitoring:** stack config lives in a repo and deploys via
  Ansible, not by hand.

## What I'd highlight in an interview

- Designing scrape topology around the *network and security* model, not just
  "point Prometheus at things."
- Using observability to drive a concrete, measured capacity fix — and making it
  reversible.
- Knowing when *not* to over-engineer (CPU was idle; the real problem was memory).

## Skills demonstrated

`Prometheus` · `Grafana` · `Loki` · `node_exporter` · `CloudWatch / CloudMonitor` ·
`capacity planning` · `Linux performance tuning` · `network security design`
