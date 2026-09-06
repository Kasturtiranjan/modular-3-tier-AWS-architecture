# Production-Ready Modular 3-Tier AWS Architecture (Terraform)

A production-grade, highly available, fault-tolerant, and secure 3-tier AWS cloud infrastructure provisioned using **Infrastructure as Code (IaC)** with modular **Terraform**. 

This architecture strictly separates the **Presentation Tier**, **Application Tier**, and **Database Tier** across multiple Availability Zones (AZs) inside a custom VPC, adhering to the AWS Well-Architected Framework.

---

## 🏗️ Architecture Overview

```text
                     [ Internet ]
                          │
                          ▼
             [ Internet Gateway (IGW) ]
                          │
     ┌────────────────────┴────────────────────┐
     │           Public Subnets (AZ1 & AZ2)   │
     │   ┌────────────────────────────────┐   │
     │   │ Application Load Balancer(ALB) │   │
     │   └───────────────┬────────────────┘   │
     │                   │ (NAT Gateways)     │
     └───────────────────┼────────────────────┘
                         │
     ┌───────────────────┼────────────────────┐
     │      Private App Subnets (AZ1 & AZ2)   │
     │   ┌───────────────▼────────────────┐   │
     │   │ Auto Scaling Group (EC2)       │   │
     │   └───────────────┬────────────────┘   │
     └───────────────────┼────────────────────┘
                         │
     ┌───────────────────┼────────────────────┐
     │      Private DB Subnets (AZ1 & AZ2)    │
     │   ┌───────────────▼────────────────┐   │
     │   │  Amazon RDS (PostgreSQL/MySQL) │   │
     │   └────────────────────────────────┘   │
     └────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack & Key Technologies

| Category | Technology | Usage / Description |
| :--- | :--- | :--- |
| **IaC & Automation** | **Terraform (v1.5+)** | Declarative infrastructure provisioning and state management |
| **Cloud Provider** | **Amazon Web Services (AWS)** | Primary cloud platform hosting all network, compute, and data resources |
| **Networking** | **AWS VPC, IGW, NAT, Route Tables** | Multi-AZ network segmentation with public, private app, and private DB subnets |
| **Load Balancing** | **AWS ALB (Application Load Balancer)** | Layer 7 load balancing with health checks and SSL termination |
| **Compute** | **Amazon EC2 & Auto Scaling** | Elastic compute capacity running backend application logic in private subnets |
| **Database** | **Amazon RDS (PostgreSQL/MySQL)** | Managed Multi-AZ relational database layer shielded from direct internet access |
| **Security** | **AWS Security Groups & IAM** | Stateful firewalls implementing least-privilege principle and strict ingress/egress rules |
| **State Storage** | **AWS S3 + DynamoDB** | Remote backend state storage with state locking capability |

---

## 📐 Architecture Layers

### 1. Networking Tier (VPC)
- Custom VPC with CIDR `10.0.0.0/16`.
- Distributed across 2 Availability Zones (`us-east-1a` / `us-east-1b`).
- 2x Public Subnets (for ALB & NAT Gateways).
- 2x Private Application Subnets (for EC2 Auto Scaling Instances).
- 2x Private Database Subnets (for Amazon RDS).

### 2. Presentation Tier (Web / Ingress)
- Public-facing **Application Load Balancer (ALB)** receiving HTTP/HTTPS traffic.
- Health check endpoints to monitor application instance readiness.

### 3. Application Tier (Compute)
- EC2 instances in private subnets with **no direct internet exposure**.
- Managed via an **Auto Scaling Group (ASG)** scaling dynamically based on CPU/RAM thresholds.
- Outbound internet access provided via redundant **NAT Gateways** for updates/patches.

### 4. Database Tier (Persistence)
- **Amazon RDS** deployed in isolated Private DB Subnets.
- Multi-AZ deployment for automated failover and redundancy.
- Non-publicly accessible. Strict inbound access allowed **only** from the Application Security Group.

---

## 📂 Repository Structure

```text
.
├── main.tf                 # Root module configuration & module calls
├── variables.tf            # Global variables definition
├── outputs.tf              # Root outputs (ALB DNS, VPC ID, etc.)
├── terraform.tfvars        # Default environment values
├── provider.tf             # AWS Provider & Remote State Backend setup
└── modules/
    ├── vpc/                # VPC, Subnets, Gateways, Route Tables
    ├── security/           # Layered Security Groups
    ├── alb/                # ALB, Target Groups, Listeners
    ├── ec2_asg/            # Launch Template, Auto Scaling Group
    └── rds/                # RDS Subnet Group, DB Instance
```

---

## 🚀 Step-by-Step Deployment Guide

### Prerequisites
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate IAM permissions (`aws configure`).
- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (v1.3.0 or higher).
- An existing S3 Bucket & DynamoDB table for remote state storage (optional, but recommended).

---

### Step 1: Clone the Repository
```bash
git clone https://github.com/your-username/aws-modular-3tier-terraform.git
cd aws-modular-3tier-terraform
```

### Step 2: Configure Backend & Provider
Update `provider.tf` with your AWS region and S3 backend config:
```hcl
terraform {
  required_version = ">= 1.5.0"
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "3-tier-architecture/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}
```

### Step 3: Customize Input Variables
Edit `terraform.tfvars` according to your environment requirements:
```hcl
aws_region          = "us-east-1"
environment         = "production"
vpc_cidr            = "10.0.0.0/16"
db_name             = "appdb"
db_username         = "adminuser"
db_password         = "ChangeMe123!Secure"
asg_min_size        = 2
asg_max_size        = 6
asg_desired_capacity = 2
instance_type       = "t3.micro"
```

### Step 4: Initialize & Validate Terraform
```bash
# Initialize working directory and download modules
terraform init

# Validate configuration syntax
terraform validate

# Format HCL files
terraform fmt -recursive
```

### Step 5: Review Execution Plan
```bash
terraform plan -out=tfplan
```

### Step 6: Apply & Provision Infrastructure
```bash
terraform apply tfplan
```

---

## 🧪 Verification & Testing

1. **Verify ALB DNS**: Fetch the ALB URL output:
   ```bash
   terraform output alb_dns_name
   ```
2. **Access Application**: Send a request to test connectivity through the load balancer:
   ```bash
   curl -I http://$(terraform output -raw alb_dns_name)
   ```
3. **Test Database Access**: Inspect application logs or connect via SSM Session Manager to verify private DB connectivity.

---

## 🧹 Tear Down / Cleanup

To avoid ongoing AWS charges, destroy all provisioned resources:
```bash
terraform destroy -auto-approve
```

---

## 🔒 Security Best Practices Implemented

- **Least Privilege Access**: Security groups explicitly allow traffic only between dependent layers (ALB ➔ EC2 ➔ RDS).
- **Private Subnet Isolation**: Backend compute and databases have zero public IP addresses.
- **Egress Control**: Private subnets reach the web exclusively through NAT Gateways.
- **Sensitive Variables**: Database passwords and credentials managed via `tfvars` (excluded via `.gitignore`) or AWS Secrets Manager.
