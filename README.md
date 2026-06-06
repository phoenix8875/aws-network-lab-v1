# AWS 3-Tier Architecture
> Production-style 3-tier architecture on AWS — built manually and as Infrastructure as Code using Terraform.

**Region:** `ap-south-1` (Mumbai) &nbsp;·&nbsp; **Stack:** Nginx → Flask → MariaDB &nbsp;·&nbsp; **IaC:** Terraform

---

## Architecture

```
          Internet
              │
         ┌────▼────┐
         │   IGW   │
         └────┬────┘
              │
┌─────────────▼──────────────────────┐
│  VPC  10.0.0.0/16                  │
│                                    │
│  ┌─────────────────────────────┐   │
│  │ Public Subnet 10.0.1.0/24  │   │
│  │  web-server · Nginx        │   │
│  │  NAT Gateway               │   │
│  └──────────────┬─────────────┘   │
│                 │ Port 5000        │
│  ┌──────────────▼─────────────┐   │
│  │ Private Subnet 10.0.2.0/24 │   │
│  │  app-server · Flask        │   │
│  └──────────────┬─────────────┘   │
│                 │ Port 3306        │
│  ┌──────────────▼─────────────┐   │
│  │ DB Subnet 10.0.3.0/24      │   │
│  │  db-server · MariaDB       │   │
│  └────────────────────────────┘   │
└────────────────────────────────────┘
```

---

## Manual Setup — Proof of Work

### VPC Resource Map
Full network topology — VPC, subnets, IGW, NAT Gateway, and route tables in one view.
![Manual VPC Resource Map](images/vpc-resource-map.png)

### EC2 Instances Running
All 3 servers provisioned across public and private subnets with correct security groups.
![Manual EC2 Instances](images/06-ec2-instances.png)

### App Working in Browser
Live Flask response served through Nginx via the web-server public IP.
![Browser Success](images/08-browser-success.png)

---

## Terraform (IaC) — Proof of Work

### Terraform Plan
`Plan: 18 to add` — 17 resources previewed before any changes hit AWS.
![Terraform Plan](images/tf-plan-output.png)

### Terraform Apply
All 18 resources created in correct dependency order — VPC → IGW → Subnets → NAT → Security Groups → EC2.
![Terraform Apply](images/tf-apply-output.png)

### Terraform VPC Resource Map
Same architecture recreated entirely from code — verified in AWS Console after apply.
![Terraform VPC Resource Map](images/tf-vpc-resource-map.png)

### Terraform EC2 Instances
All 3 `-tf1` servers running — provisioned via `terraform apply` with no manual console clicks.
![Terraform EC2 Instances](images/tf-ec2-instances.png)

---

## What's Inside

| Component | Technology | Subnet |
|---|---|---|
| Web Server | Nginx reverse proxy | Public `10.0.1.0/24` |
| App Server | Python Flask API | Private `10.0.2.0/24` |
| DB Server | MariaDB | DB Private `10.0.3.0/24` |
| Firewall | Security Group chaining | web-sg → app-sg → db-sg |
| Outbound | NAT Gateway | Public subnet |

---

## Two Approaches

| | Manual | Terraform |
|---|---|---|
| Setup | AWS Console step-by-step | `terraform apply` |
| Resources | 1 by 1 via console | 18 in one command |
| Guide | [manual-setup-steps.md](docs/manual-setup-steps.md) | [TERRAFORM_3TIER_LEARNING_v1.md](docs/TERRAFORM_3TIER_LEARNING_v1.md) |
| Network design | [ARCHITECTURE.md](architecture/ARCHITECTURE.md) | Same architecture, IaC |

---

## Quick Deploy

```bash
cd terraform-aws-labv1/
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Always destroy after testing — NAT Gateway costs ~$32/month
terraform destroy
```

---

## Prerequisites

- AWS Account + CLI configured (`aws configure`)
- Terraform >= 1.0
- Python 3.8+

---

## Project Structure

```
aws-3tier-architecture/
├── README.md
├── architecture/
│   └── ARCHITECTURE.md                  ← Network design + diagrams
├── docs/
│   ├── manual-setup-steps.md            ← Manual AWS setup with screenshots
│   └── TERRAFORM_3TIER_LEARNING_v1.md   ← Terraform IaC guide
├── src/
│   ├── app/                             ← Python Flask application
│   ├── db/                              ← Database init scripts
│   └── web/                             ← Nginx configuration
└── terraform-aws-labv1/                 ← Terraform modules
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars.example
    └── modules/
        ├── vpc/
        ├── security_groups/
        └── ec2/
```

---

## License

MIT — see [LICENSE](LICENSE)
