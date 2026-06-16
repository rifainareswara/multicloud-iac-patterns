# Cloud Cost Optimization: Consolidating 9 Load Balancers into 2 Ingress

**Theme:** FinOps · Networking · Serverless
**Stack:** Alibaba Cloud SAE, CLB (Classic Load Balancer), SAE Ingress, Cloudflare

---

## Context

The product environment ran on Alibaba Cloud's Serverless App Engine (SAE)
across two environments (dev and UAT). Each microservice — backend, frontend,
and several AI generation services (image, prompt, video) — had been provisioned
with its **own dedicated load balancer**, the default "one LB per app" pattern.

## Problem

That pattern meant **9 billable Classic Load Balancers** for what was, in
reality, a handful of HTTP services that all spoke the same protocol on port 80.
Load balancers were one of the largest line items in the monthly cloud bill
(~$234/month) with no corresponding benefit — the traffic volume did not justify
nine separate L4/L7 endpoints.

## Approach

I replaced the per-app load balancers with **one SAE Ingress per environment**
doing host-based L7 routing:

- A single Ingress per environment fronts all services on port 80 (HTTP).
- Each service is a host-based rule (`service-a.example.com → app-a:8000`,
  `service-b.example.com → app-b:3000`, …).
- A `DefaultRule` catches any unmatched host so there is always a sane fallback.
- TLS is terminated at Cloudflare (Flexible SSL, proxied), so the Ingress only
  needs to speak HTTP — no per-LB certificate management.

I validated routing **before** touching DNS by sending requests with an
explicit `Host` header directly at the Ingress IP, so the cutover was a no-drama
DNS repoint rather than a leap of faith.

Old load balancers were detached cleanly: SAE-managed LBs auto-delete on unbind,
while user-created ones were removed explicitly — important so I wasn't quietly
billed for orphaned resources after the migration.

## Architecture

```
            Before                                    After
  ┌──────┐   ┌──────┐  ... (×9)         ┌─────────── Cloudflare (TLS) ──────────┐
  │ LB 1 │   │ LB 2 │                   │                                       │
  └──┬───┘   └──┬───┘                   ▼                                       ▼
     │          │                  ┌─────────┐                            ┌─────────┐
  ┌──▼──┐    ┌──▼──┐               │ Ingress │  host-based routing        │ Ingress │
  │app 1│    │app 2│               │  (dev)  │                            │  (uat)  │
  └─────┘    └─────┘               └────┬────┘                            └────┬────┘
   1 LB per app                         │  ┌─────┬─────┬─────┐                 │
   = 9 billable LBs            ┌────────┼──┘     │     │     │            (4 apps)
                               ▼        ▼        ▼     ▼     ▼
                            backend  frontend  image prompt video
```

## Impact

- **Load balancers: 9 → 2** (one per environment)
- **Cost: ~$234/mo → savings of ~$175/mo** (≈75% reduction on this line item)
- **Zero downtime** cutover, validated with `Host`-header testing before DNS
- **Simpler operations:** one routing config per environment instead of nine
  separate LBs to reason about, plus TLS centralized at the edge

## What I'd highlight in an interview

- Recognizing that a cloud *default* (one LB per service) was a cost trap at this
  scale, and that L7 host routing collapses it without losing isolation.
- De-risking a networking cutover by testing the data path independently of DNS.
- Cleaning up orphaned resources so the saving was real, not just "stopped using."

## Skills demonstrated

`FinOps` · `Alibaba SAE` · `L7 load balancing` · `DNS / Cloudflare` ·
`zero-downtime migration` · `cloud cost governance`
