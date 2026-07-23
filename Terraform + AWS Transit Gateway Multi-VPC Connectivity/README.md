# Terraform + AWS Transit Gateway Multi-VPC Connectivity

This Terraform project provisions a multi-VPC architecture on AWS using **AWS Transit Gateway** to enable connectivity between two VPCs. It deploys a public-facing EC2 instance in a public VPC and a private EC2 instance in a private VPC, connected via Transit Gateway for cross-VPC communication.

## Architecture Overview

```
                          ┌───────────────────────────┐
                          │   AWS Transit Gateway      │
                          │       (DemoTG)             │
                          └────┬──────────────────┬────┘
                               │                  │
                    Attachment 1            Attachment 2
                               │                  │
                    ┌──────────▼──────┐  ┌───────▼──────────┐
                    │   First VPC     │  │   Second VPC     │
                    │  10.0.0.0/24    │  │  20.0.0.0/24     │
                    │                 │  │                  │
                    │ Public Subnet   │  │ Private Subnet   │
                    │ 10.0.0.0/25     │  │ 20.0.0.0/25      │
                    │                 │  │                  │
                    │   ┌─────────┐   │  │  ┌──────────┐    │
                    │   │  EC2    │   │  │  │   EC2    │    │
                    │   │ Public  │   │  │  │  Private │    │
                    │   └─────────┘   │  │  └──────────┘    │
                    │        ▲        │  │                  │
                    │        │        │  │                  │
                    │   ┌─────────┐   │  │                  │
                    │   │   IGW   │   │  │                  │
                    │   └─────────┘   │  │                  │
                    └─────────────────┘  └──────────────────┘
```

## Resources Created

| Resource | Name | Description |
|----------|------|-------------|
| **VPC** | `First_VPC` | Public VPC with CIDR `10.0.0.0/24` |
| **VPC** | `Second_VPC` | Private VPC with CIDR `20.0.0.0/24` |
| **Subnet** | `Public_subnet_first_VPC` | Public subnet in First VPC (`10.0.0.0/25`) |
| **Subnet** | `private_subnet_second_vpc` | Private subnet in Second VPC (`20.0.0.0/25`) |
| **Internet Gateway** | `IGW` | Attached to First VPC for public internet access |
| **Route Table** | `PublicRT` | Public route table with route to IGW (0.0.0.0/0) |
| **Route Table Association** | `public_subnet_association` | Associates public subnet with public route table |
| **Security Group** | `whiz_sg` | Public SG - allows SSH (22), HTTP (80), HTTPS (443) |
| **Security Group** | `whiz_sg2` | Private SG - allows SSH (22) only |
| **EC2 Instance** | `First_VPCs_EC2` | Public EC2 with Apache httpd (t2.micro) |
| **EC2 Instance** | `Second_VPCs_EC2` | Private EC2 with Apache httpd (t2.micro, no public IP) |
| **Transit Gateway** | `DemoTG` | Connects both VPCs |
| **TGW Attachment** | `first_vpc_tga` | Attaches First VPC to Transit Gateway |
| **TGW Attachment** | `second_vpc_tga` | Attaches Second VPC to Transit Gateway |
| **Route** | `first_vpc_route_to_second_vpc` | Route from First VPC to Second VPC via TGW |
| **Route** | `second_vpc_route_to_first_vpc` | Route from Second VPC to First VPC via TGW |

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) (v1.x or later)
- AWS account with appropriate permissions
- AWS Access Key and Secret Key
- An existing SSH key pair named `MySSHKey` in the `us-east-1` region (or modify the `key_name` in `main.tf`)
- An IAM instance profile named `ContainerInstanceEC2Role` (or modify the `iam_instance_profile` in `main.tf`)

## Project Structure

```
├── main.tf                 # Main Terraform configuration with all resources
├── variables.tf            # Input variable definitions
├── terraform.tfvars        # Variable values (AWS credentials, region)
├── output.tf               # Output definitions
├── terraform.tfstate       # Terraform state file (auto-generated)
├── terraform.tfstate.backup # Terraform state backup (auto-generated)
├── .terraform.lock.hcl     # Dependency lock file (auto-generated)
└── README.md               # Project documentation
```

## Usage

### 1. Clone / Navigate to the Project

```bash
cd "Terraform + AWS Transit Gateway Multi-VPC Connectivity"
```

### 2. Configure AWS Credentials

Edit the `terraform.tfvars` file and replace the placeholder values with your actual AWS credentials:

```hcl
region     = "us-east-1"
access_key = "YOUR_ACCESS_KEY_HERE"
secret_key = "YOUR_SECRET_KEY_HERE"
```

> **⚠️ Security Note:** Never commit your actual AWS credentials to version control. For production use, consider using AWS CLI credential profiles or environment variables instead.

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Plan

```bash
terraform plan
```

### 5. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 6. Destroy Resources (Cleanup)

```bash
terraform destroy
```

Type `yes` when prompted to destroy all provisioned resources.

## Input Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `region` | AWS region to deploy resources | `us-east-1` |
| `access_key` | AWS Access Key ID | (required) |
| `secret_key` | AWS Secret Access Key | (required) |

## Outputs

| Output | Description |
|--------|-------------|
| `first_vpc_id` | ID of the First VPC |
| `second_vpc_id` | ID of the Second VPC |
| `public_subnet_first_vpc_id` | ID of the public subnet in First VPC |
| `private_subnet_second_vpc_id` | ID of the private subnet in Second VPC |
| `internet_gateway_id` | ID of the Internet Gateway |
| `public_route_table_id` | ID of the public route table |
| `public_ec2_sg_id` | Security Group ID for the public EC2 instance |
| `private_ec2_sg_id` | Security Group ID for the private EC2 instance |
| `public_ec2_instance_id` | Instance ID of the public EC2 |
| `public_ec2_instance_public_ip` | Public IP of the public EC2 instance |
| `private_ec2_instance_id` | Instance ID of the private EC2 |
| `transit_gateway_id` | ID of the Transit Gateway |
| `transit_gateway_attachment_first_vpc_id` | TGW attachment ID for First VPC |
| `transit_gateway_attachment_second_vpc_id` | TGW attachment ID for Second VPC |

## Testing Connectivity

Once deployed, you can test cross-VPC connectivity:

1. **Access the public EC2 instance** via its public IP on HTTP:
   ```bash
   curl http://<public_ec2_instance_public_ip>
   ```
   You should see: *"Welcome to Public Server"*

2. **SSH into the public EC2 instance**, then from there curl the **private EC2 instance** (using its private IP) to verify Transit Gateway connectivity:
   ```bash
   ssh -i MySSHKey.pem ec2-user@<public_ec2_public_ip>
   curl http://<private_ec2_private_ip>
   ```
   You should see: *"Welcome to Private Server"*

## Notes

- Both EC2 instances use Amazon Linux 2023 AMI (`ami-0b09ffb6d8b58ca91` in `us-east-1`).
- The private EC2 instance does **not** have a public IP and relies on the Transit Gateway for connectivity to the public VPC.
- The user data scripts install and start Apache HTTPD server on both instances automatically.
- Ensure that the `MySSHKey` key pair exists in your AWS account before deploying.
- Ensure the IAM role `ContainerInstanceEC2Role` exists in your AWS account, or remove/update the `iam_instance_profile` attribute in `main.tf`.

