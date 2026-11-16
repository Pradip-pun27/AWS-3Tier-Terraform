# AWS 3-Tier Web Application Architecture with Terraform

A fully automated, highly available, fault-tolerant **3-Tier Web Architecture** on AWS provisioned from scratch using **Terraform (Infrastructure as Code)**.

The stack deploys a decoupled **HTML5/CSS3/Vanilla JS** frontend, a **PHP 8.3 (PDO)** REST API running on an auto-scaled fleet of **Ubuntu 24.04 EC2** instances inside private subnets, and an isolated **Amazon RDS MySQL 8.0** database—fronted by an internet-facing **Application Load Balancer (ALB)**.

---

## Architecture Overview

```text
                           [ Internet Users ]
                                   │
                            HTTP (Port 80)
                                   ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ TIER 1: PRESENTATION TIER (Public Subnets across 2 Availability Zones)  │
│   • Application Load Balancer (ALB) — Public DNS Entrypoint             │
│   • NAT Gateway + Elastic IP — Outbound internet for private EC2s       │
└──────────────────────────────────┬──────────────────────────────────────┘
                                   │  Forwards HTTP (Port 80) internally
                                   ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ TIER 2: APPLICATION TIER (Private Subnets across 2 Availability Zones)  │
│   • EC2 Auto Scaling Group (Min: 1 | Desired: 2 | Max: 3)               │
│   • Ubuntu 24.04 LTS + Apache2 + PHP 8.3 (PDO) + HTML/JS Frontend       │
│   • Zero Public IPs assigned to application servers                     │
└──────────────────────────────────┬──────────────────────────────────────┘
                                   │  MySQL TCP (Port 3306) internally
                                   ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ TIER 3: DATA TIER (Isolated DB Subnets across 2 Availability Zones)     │
│   • Amazon RDS MySQL 8.0 (Publicly Accessible = False)                  │
│   • Route table has NO Internet Gateway and NO NAT Gateway              │
└─────────────────────────────────────────────────────────────────────────┘



.
├── .gitignore                 # Excludes local state, .terraform cache, and secrets
├── README.md                  # Project documentation
├── providers.tf               # Terraform & AWS provider configuration
├── variables.tf               # Parameterized inputs & validation rules
├── terraform.tfvars.example   # Example variable configuration
├── network.tf                 # Custom VPC, 6 subnets, IGW, NAT Gateway & Route Tables
├── security.tf                # Chained Security Groups for Presentation, App & Data tiers
├── database.tf                # RDS Subnet Group & Private MySQL 8.0 instance
├── compute.tf                 # Ubuntu 24.04 AMI lookup, Launch Template & ASG
├── alb.tf                     # Application Load Balancer, Target Group & HTTP Listener
├── user_data.sh.tftpl         # Server bootstrap script & PHP/HTML application source
└── outputs.tf                 # Deployment outputs (ALB URL, VPC ID, RDS endpoint)

## Configure your variables
Copy the example variables file and set a strong database password:
- cp terraform.tfvars.example terraform.tfvars
- nano terraform.tfvars

## Finally now you are good to go with:
- terraform init
- terraform plan
- terraform apply -auto-approve

### Don't worry and no rush, It will take some minute to give u the output because intotal 30 resources will be created if I'm right
### After some time copy that 'application_url' variable's value that appeared on yr terminal to access the application 

### Hey never forget to run 'terraform destory -auto-approve' after you are done otherwise u will get a huge aws bill :)