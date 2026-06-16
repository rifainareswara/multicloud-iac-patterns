# Architecture Diagrams

Sanitized diagrams of the multi-cloud platform. Written in [Mermaid](https://mermaid.js.org/) —
they render natively on GitHub/GitLab and on most static-site generators
(or paste into <https://mermaid.live> to export PNG/SVG for a portfolio site).

Company names, public IPs, resource IDs, and domains are placeholders;
topology and decisions are real.

---

## 1. Multi-cloud platform — control plane & estate

How code becomes infrastructure across three clouds and the self-hosted stack.

```mermaid
flowchart TB
    subgraph SRC["Source of truth + CI/CD"]
        GL["GitLab CI<br/>(self-hosted)"]
        GH["GitHub Actions<br/>(mirror + scheduled jobs)"]
        GL <-->|mirror| GH
    end

    subgraph CTRL["Control plane (IaC)"]
        TF["Terraform<br/>~320 modules"]
        ANS["Ansible<br/>roles / playbooks"]
        VAULT["HashiCorp Vault<br/>(secrets)"]
        ANS --> VAULT
    end

    SRC --> CTRL

    subgraph CLOUDS["Managed estate"]
        direction LR
        subgraph ALI["Alibaba Cloud (primary)"]
            SAE["SAE<br/>serverless apps"]
            ECS["ECS"]
            DB[("Managed DB / Redis")]
        end
        subgraph AWS["AWS"]
            EC2["EC2 / services"]
        end
        subgraph GCP["GCP"]
            GSVC["GCP services"]
        end
    end

    subgraph SELF["Self-hosted (Docker Compose via Ansible)"]
        direction LR
        S1["GitLab"]
        S2["SonarQube"]
        S3["Vault"]
        S4["Wiki.js / OpenProject"]
    end

    TF --> ALI
    TF --> AWS
    TF --> GCP
    ANS --> SELF
    ANS --> ECS
    GH -->|scheduled cost jobs| SAE
```

---

## 2. Load-balancer consolidation — before vs. after

The FinOps win: 9 dedicated load balancers collapsed into 1 host-routing Ingress
per environment (~75% cost cut). See
[case study 01](./01-cost-optimization-clb-consolidation.md).

### Before — one load balancer per app (9 billable LBs)

```mermaid
flowchart LR
    U["Users"] --> LB1["LB 1"] --> A1["backend"]
    U --> LB2["LB 2"] --> A2["frontend"]
    U --> LB3["LB 3"] --> A3["generate-image"]
    U --> LB4["LB 4"] --> A4["generate-prompt"]
    U --> LB5["LB 5"] --> A5["generate-video"]
    U --> LBn["LB 6..9<br/>(UAT apps)"] --> An["..."]
```

### After — Cloudflare TLS + 1 Ingress per environment (2 LBs total)

```mermaid
flowchart TB
    U["Users"] --> CF["Cloudflare<br/>(TLS termination,<br/>Flexible SSL)"]

    CF -->|"*.dev.example.com"| INGD["SAE Ingress — dev<br/>HTTP :80, host-based"]
    CF -->|"*.uat.example.com"| INGU["SAE Ingress — uat<br/>HTTP :80, host-based"]

    INGD -->|backend.dev| BD["backend :4000"]
    INGD -->|app.dev| FD["frontend :3000"]
    INGD -->|image.dev| ID["generate-image :8000"]
    INGD -->|prompt.dev| PD["generate-prompt :8000"]
    INGD -.->|"DefaultRule"| VD["generate-video :8000"]

    INGU -->|backend.uat| BU["backend"]
    INGU -.->|"DefaultRule"| FU["frontend"]
    INGU -->|image.uat| IU["generate-image"]
    INGU -->|video.uat| VU["generate-video"]
```

---

## 3. Centralized observability — scrape topology

Security-aware metrics collection: private-VPC scraping on Alibaba, IP-locked
public scraping on AWS. See [case study 04](./04-observability-fleet-monitoring.md).

```mermaid
flowchart TB
    subgraph MON["Central monitoring host"]
        PROM["Prometheus"]
        GRAF["Grafana<br/>monitoring.example.com"]
        LOKI["Loki"]
        PROM --> GRAF
        LOKI --> GRAF
    end

    subgraph ALI["Alibaba VPC (private subnet)"]
        N1["gitlab · node_exporter"]
        N2["app servers · node_exporter"]
    end

    subgraph AWS["AWS"]
        N3["hosts · node_exporter"]
    end

    subgraph EXP["Cloud-native exporters"]
        CM["CloudMonitor (Alibaba)"]
        CW["CloudWatch (AWS)"]
        GB["GCP billing"]
    end

    PROM -->|"private IP scrape<br/>SG: monitor IP only"| ALI
    PROM -->|"public EIP scrape<br/>SG: locked to monitor IP"| AWS
    PROM --> EXP
```

---

## 4. Production request flow (Alibaba SAE)

End-to-end path of a user request in the consolidated architecture.

```mermaid
sequenceDiagram
    actor User
    participant CF as Cloudflare (TLS)
    participant ING as SAE Ingress (:80 HTTP)
    participant APP as SAE App (container :8000)
    participant DB as Managed DB / Redis

    User->>CF: HTTPS request (app.example.com)
    CF->>ING: HTTP, forwards Host header
    ING->>ING: Host-based rule match → target app
    ING->>APP: route to app:containerPort
    APP->>DB: query / cache
    DB-->>APP: result
    APP-->>ING: 200 OK
    ING-->>CF: response
    CF-->>User: HTTPS response
```

---

## Exporting for a portfolio site

- **GitHub/GitLab:** these render automatically in Markdown — no setup.
- **PNG/SVG:** paste a block into <https://mermaid.live>, export, embed the image.
- **Static sites (Hugo, Astro, Docusaurus, MkDocs Material):** all support
  Mermaid via a plugin/shortcode — drop the fenced ` ```mermaid ` blocks in.
