# Terraform — AWS 3-Tier Architecture
### Region: `ap-south-1` (Mumbai) · Suffix: `-tf1` · Stack: VPC → Security Groups → EC2

> **Purpose:** Infrastructure-as-Code version of the manual 3-tier AWS lab. Every resource is modular, reusable, and version-controlled.

---

## What We Built

```
          ┌─────────────────────────────────────────┐
          │               Internet                  │
          └──────────┬─────────────────┬────────────┘
                     │ Port 80 (HTTP)  │ Outbound only
                     ▼                 ▼
          ┌─────────────────┐ ┌─────────────────┐
          │ web-server-tf1  │ │  NAT Gateway    │
          │ (Nginx Proxy)   │ │  nat-tf1        │
          │ web-sg-tf1      │ │  (public subnet)│
          │ Public IP ✅    │ └────────┬────────┘
          └────────┬────────┘          │ outbound
                   │ Port 5000         │ for private
                   ▼                   │ servers
          ┌─────────────────┐          │
          │ app-server-tf1  │◄─────────┘
          │ (Flask API)     │  ap-south-1a
          │ app-sg-tf1      │  No Public IP ❌
          └────────┬────────┘
                   │ Port 3306
                   ▼
          ┌─────────────────┐
          │  db-server-tf1  │  ap-south-1b
          │  (MariaDB)      │  No Public IP ❌
          │  db-sg-tf1      │
          └─────────────────┘
```

---

## Project Structure

```
terraform-aws-labv1/
├── main.tf                   ← Root orchestrator
├── variables.tf              ← Root input declarations
├── outputs.tf                ← Prints to terminal after apply
├── terraform.tfvars          ← Your real values (gitignored)
├── terraform.tfvars.example  ← Safe template to commit
├── backend.tf                ← Empty (local state for now)
└── modules/
    ├── vpc/                  ← Network foundation + NAT
    │   ├── variables.tf
    │   ├── main.tf
    │   └── outputs.tf
    ├── security_groups/      ← Firewall rules
    │   ├── variables.tf
    │   ├── main.tf
    │   └── outputs.tf
    └── ec2/                  ← The three servers
        ├── variables.tf
        ├── main.tf
        └── outputs.tf
```

---

## How All Files Connect

```mermaid
flowchart TD
    TFV["📄 terraform.tfvars\nReal values\nvpc_cidr, ami_id, key_name..."]
    RV["📄 root/variables.tf\nDeclares all root inputs"]
    RM["📄 root/main.tf\nOrchestrator — calls all modules"]
    RO["📄 root/outputs.tf\nPrints IPs + IDs to terminal"]

    TFV -->|feeds values into| RV
    RV -->|available as var.xyz in| RM
    RM -->|calls| VPC
    RM -->|calls| SG
    RM -->|calls| EC2
    RM --> RO

    subgraph VPC["🗂️ modules/vpc/"]
        VV["variables.tf\nvpc_cidr\npublic_subnet_cidr\nprivate_subnet_cidrs\navailability_zones\nproject_name"]
        VM["main.tf\naws_vpc\naws_subnet x3\naws_internet_gateway\naws_eip\naws_nat_gateway\naws_route_table x2\naws_route_table_association x3"]
        VO["outputs.tf\nvpc_id\npublic_subnet_id\napp_subnet_id\ndb_subnet_id"]
        VV --> VM --> VO
    end

    subgraph SG["🗂️ modules/security_groups/"]
        SGV["variables.tf\nvpc_id\nproject_name"]
        SGM["main.tf\nweb-sg-tf1\napp-sg-tf1\ndb-sg-tf1"]
        SGO["outputs.tf\nweb_sg_id\napp_sg_id\ndb_sg_id"]
        SGV --> SGM --> SGO
    end

    subgraph EC2["🗂️ modules/ec2/"]
        EV["variables.tf\nami_id, instance_type\nkey_name\n3x subnet_ids\n3x sg_ids"]
        EM["main.tf\nweb-server-tf1\napp-server-tf1\ndb-server-tf1"]
        EO["outputs.tf\nweb_server_public_ip\napp_server_private_ip\ndb_server_private_ip"]
        EV --> EM --> EO
    end

    VO -->|"module.vpc.vpc_id\nmodule.vpc.public_subnet_id\nmodule.vpc.app_subnet_id\nmodule.vpc.db_subnet_id"| RM
    SGO -->|"module.security_groups.web_sg_id\nmodule.security_groups.app_sg_id\nmodule.security_groups.db_sg_id"| RM
    EO -->|"module.ec2.web_server_public_ip\nmodule.ec2.app_server_private_ip"| RO
```

---

## Module 1 — VPC

**What it does:** Builds the entire network — VPC, subnets, IGW, NAT Gateway, and route tables.

```mermaid
flowchart LR
    VPC["aws_vpc.main\n10.0.0.0/16"]

    PUB["aws_subnet.public\n10.0.1.0/24\nap-south-1a\nPublic IP ✅"]
    APP["aws_subnet.private[0]\n10.0.2.0/24\nap-south-1a"]
    DB["aws_subnet.private[1]\n10.0.3.0/24\nap-south-1b"]

    IGW["aws_internet_gateway"]
    EIP["aws_eip.nat\nStatic Public IP"]
    NAT["aws_nat_gateway\nSits in public subnet"]

    PRT["route_table public\n0.0.0.0/0 → IGW"]
    PRIV["route_table private\n0.0.0.0/0 → NAT"]

    VPC --> PUB & APP & DB & IGW
    IGW --> PRT
    EIP --> NAT
    PUB --> NAT
    NAT --> PRIV
    PRT -->|associated| PUB
    PRIV -->|associated| APP & DB
```

| Resource | Name Tag | Purpose |
|---|---|---|
| `aws_vpc` | `myproject-vpc-tf1` | Isolated network container |
| `aws_subnet` public | `myproject-public-tf1` | Web tier, auto public IP |
| `aws_subnet` private[0] | `myproject-private-tf1` | App tier, no public IP |
| `aws_subnet` private[1] | `myproject-db-private-tf1` | DB tier, separate AZ |
| `aws_internet_gateway` | `myproject-igw-tf1` | Door to internet for public subnet |
| `aws_eip` | `myproject-nat-eip-tf1` | Static IP required by NAT Gateway |
| `aws_nat_gateway` | `myproject-nat-tf1` | Outbound-only internet for private subnets |
| `aws_route_table` public | `myproject-public-rt-tf1` | Routes 0.0.0.0/0 → IGW |
| `aws_route_table` private | `myproject-private-rt-tf1` | Routes 0.0.0.0/0 → NAT |

**NAT Gateway vs Internet Gateway:**
```
Internet Gateway  → two-way  → public subnet  (web-server can receive inbound)
NAT Gateway       → one-way  → private subnet (app/db can call out, nobody can call in)
```

![NAT-Gateway](images/tf-nat.png) 

![Route table](images/tfnat-route-tabl2.png)


**Key concept — `count` for looping:**
```hcl
resource "aws_subnet" "private" {
  count             = 2                                      # loops twice
  cidr_block        = var.private_subnet_cidrs[count.index]  # [0]=app [1]=db
  availability_zone = var.availability_zones[count.index]
}
```

**Outputs passed to other modules:**
```
vpc_id            → security_groups module
public_subnet_id  → ec2 module (web-server placement)
app_subnet_id     → ec2 module (app-server placement)
db_subnet_id      → ec2 module (db-server placement)
```

![subnet](images/tfvpc-subnets.png) — VPC and subnet list from AWS console
 ![route-table](images/tfnat-route-table.png) — Route tables showing public/private separation
---

## Module 2 — Security Groups

**What it does:** Creates 3 security groups with strict chaining — each tier only accepts traffic from the tier directly above it.

```mermaid
flowchart TD
    NET["🌐 Internet"]
    WEB["web-sg-tf1\nPort 80 → 0.0.0.0/0\nPort 22 → 0.0.0.0/0"]
    APP["app-sg-tf1\nPort 5000 → web-sg-tf1 ID only\nPort 22  → web-sg-tf1 ID only"]
    DB["db-sg-tf1\nPort 3306 → app-sg-tf1 ID only\nPort 22  → app-sg-tf1 ID only"]

    NET -->|"HTTP Port 80"| WEB
    WEB -->|"Flask Port 5000\nsecurity_group reference"| APP
    APP -->|"MySQL Port 3306\nsecurity_group reference"| DB
```

**Security group chaining — the key pattern:**
```hcl
# NOT a CIDR range like "10.0.0.0/16"
# Reference the actual security group ID instead
ingress {
  from_port       = 5000
  security_groups = [aws_security_group.web_sg.id]
}
```
Even an EC2 inside the same VPC **cannot** reach the app tier unless it belongs to `web-sg-tf1`. Identity-based access — not IP-based.

![web-sg](images/tf-web-sg.png) — web-sg inbound rules in AWS console
![app-sg](images/tf-app-sg.png) — app-sg showing source as web-sg ID
![db-sg](images/tf-db-sg.png) — db-sg showing source as app-sg ID

---

## Module 3 — EC2

**What it does:** Deploys 3 servers, each placed in the correct subnet with the correct security group attached.

```mermaid
flowchart LR
    subgraph PUBLIC["Public Subnet — ap-south-1a"]
        WS["web-server-tf1\nt3.micro · Amazon Linux 2\nPublic IP ✅\nweb-sg-tf1"]
    end
    subgraph PRIVATE["Private Subnet — ap-south-1a"]
        AS["app-server-tf1\nt3.micro · Amazon Linux 2\nNo Public IP ❌\napp-sg-tf1"]
    end
    subgraph DBPRIVATE["DB Private Subnet — ap-south-1b"]
        DS["db-server-tf1\nt3.micro · Amazon Linux 2\nNo Public IP ❌\ndb-sg-tf1"]
    end
    WS --> AS --> DS
```

| Server | Subnet | Public IP | Security Group | Role |
|---|---|---|---|---|
| `web-server-tf1` | public-tf1 | ✅ Yes | web-sg-tf1 | Nginx reverse proxy |
| `app-server-tf1` | private-tf1 | ❌ No | app-sg-tf1 | Flask API |
| `db-server-tf1` | db-private-tf1 | ❌ No | db-sg-tf1 | MariaDB |

**Spec (all 3 instances):**
```
AMI           : ami-00c5d5e886a26d124  (Amazon Linux 2, Mumbai)
Instance type : t3.micro
Key pair      : network-lab-key
```

**Outputs printed to terminal after apply:**
```bash
web_server_public_ip   = "13.235.xx.xx"   # open in browser
app_server_private_ip  = "10.0.2.x"       # SSH jump / Flask config
db_server_private_ip   = "10.0.3.x"       # MariaDB connection string
```

![Instances running](images/tf-instances.png) 
---

## Root Files

### `root/main.tf` — The Orchestrator

Calls every module and wires outputs between them. Modules **never talk to each other directly** — everything routes through here.

```mermaid
flowchart TD
    RM["root/main.tf"]
    VM["module.vpc"]
    SM["module.security_groups"]
    EM["module.ec2"]

    RM -->|"project_name, vpc_cidr\npublic_subnet_cidr\nprivate_subnet_cidrs\navailability_zones"| VM
    VM -->|"vpc_id\npublic_subnet_id\napp_subnet_id\ndb_subnet_id"| RM
    RM -->|"project_name\nvpc_id"| SM
    SM -->|"web_sg_id\napp_sg_id\ndb_sg_id"| RM
    RM -->|"ami_id, instance_type, key_name\nsubnet_ids ← from vpc\nsg_ids ← from sg"| EM
```

### `terraform.tfvars` — Your Values (gitignored)

The **only file** you edit when switching environments. Same modules, different values = different environment.

```hcl
aws_region           = "ap-south-1"
project_name         = "myproject"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidr   = "10.0.1.0/24"
private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
availability_zones   = ["ap-south-1a", "ap-south-1b"]
ami_id               = "ami-00c5d5e886a26d124"
instance_type        = "t3.micro"
key_name             = "network-lab-key"
```

### `backend.tf` — State Config (empty for now)

Local state used during learning. For teams: migrate to S3 + DynamoDB.

```hcl
# Future upgrade when working in teams
terraform {
  backend "s3" {
    bucket         = "myproject-tfstate"
    key            = "3tier/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "myproject-tf-locks"
  }
}
```

---

## Terraform Commands

```bash
# 1. First time setup — downloads AWS provider, initialises modules
terraform init

# 2. Preview what will be created — NO changes made to AWS
terraform plan

# 3. Save plan to file — what you reviewed = exactly what runs
terraform plan -out=tfplan

# 4. Apply the saved plan
terraform apply tfplan

# 5. Apply without saved plan — asks for confirmation
terraform apply

# 6. Tear everything down — removes ALL resources including NAT Gateway
terraform destroy

# 7. Print outputs again without re-applying
terraform output

# 8. List every resource Terraform is tracking
terraform state list
```

**Why save a plan?**
```
terraform plan -out=tfplan   ← snapshot of what WILL happen
terraform apply tfplan        ← applies that exact snapshot
                                what you reviewed = what runs ✅
```

---

## State File

```
terraform.tfstate   ← auto-created after first apply
                      tracks every resource Terraform manages
                      NEVER edit manually
                      NEVER commit to Git  ← already in .gitignore
```

**`terraform destroy` removes everything tracked in state:**
```
NAT Gateway    ✅ destroyed
Elastic IP     ✅ destroyed
EC2 instances  ✅ destroyed
Security Groups✅ destroyed
Subnets        ✅ destroyed
VPC            ✅ destroyed
Zero cost after destroy ✅
```

---

## `.gitignore` (Already Configured)

```
*.tfstate          # never commit state
*.tfstate.*
.terraform/        # provider binaries
.terraform.lock.hcl
*.tfvars           # never commit real values
```

> Always commit `terraform.tfvars.example` with dummy values so anyone cloning knows the required inputs.

---

## Resource Summary

| Module | Resources Created | Outputs Exposed |
|---|---|---|
| vpc | 11 | 4 |
| security_groups | 3 | 3 |
| ec2 | 3 | 6 |
| **Total** | **17** | **13** |

---

> **Revision tip:** Value flow is always one direction —
> `tfvars → root variables → root main → module variables → module main → module outputs → root main → root outputs`
> Follow that chain on any Terraform project and it will make sense immediately.
