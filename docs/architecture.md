# Architecture

Sanitized diagrams (Mermaid — render natively on GitHub).

## Control plane: code → infrastructure

```mermaid
flowchart TB
    SRC["Git (CI/CD)"] --> TF["Terraform (~320 modules)"]
    SRC --> ANS["Ansible + Vault"]
    TF --> ALI["Alibaba Cloud"]
    TF --> AWS["AWS"]
    TF --> GCP["GCP"]
    ANS --> SELF["Self-hosted stack (Docker Compose)"]
```

## Request flow (consolidated ingress)

```mermaid
flowchart LR
    U["Users"] --> CF["Cloudflare (TLS)"]
    CF --> ING["SAE Ingress :80 (host-based)"]
    ING -->|backend.*| B["backend"]
    ING -->|app.*| F["frontend"]
    ING -->|image.*| I["generate-image"]
    ING -.->|DefaultRule| V["generate-video"]
```

## Observability scrape topology

```mermaid
flowchart TB
    PROM["Prometheus"] --> GRAF["Grafana"]
    PROM -->|"private VPC, SG-locked"| ALI["Alibaba node_exporters"]
    PROM -->|"public EIP, IP-locked"| AWS["AWS node_exporters"]
    PROM --> EXP["CloudMonitor / CloudWatch exporters"]
```

> Full write-ups (problem → approach → impact) live with my portfolio case
> studies.
