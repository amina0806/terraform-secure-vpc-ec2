# ISO/IEC 27001:2022 Control Mapping — Secure VPC + EC2 Terraform Project

This project is designed to progressively harden an AWS environment from a simple public demo (Step 1) to a private, compliance-ready deployment (Step 3).  
Each step addresses specific ISO/IEC 27001:2022 Annex A controls.

---

## Step 1 — Public EC2 Demo (Baseline)
**Security objective:** Establish a working baseline with minimal public exposure and controlled inbound access.

| ISO Control | Control Name | Implementation in Terraform |
|-------------|--------------|------------------------------|
| A.5.15 | **Least privilege** | Security Group allows SSH only from my public IP (/32) |
| A.8.20 | **Network security controls** | Public subnet with IGW; inbound rules restricted by SG |
| A.8.9 | **Configuration management** | Terraform enforces SG rules and resource naming |

**Risks still present:**  
- Instance has a public IP (internet-exposed).  
- SSH access still relies on key management.  
- No segmentation between public and private workloads.

---

## Step 2 — Private Subnets + ALB + SSM
**Security objective:** Eliminate direct public access to workloads, enforce network segregation, and remove SSH exposure.

| ISO Control | Control Name | Implementation in Terraform |
|-------------|--------------|------------------------------|
| A.5.18 | **Access to privileged utilities** | Admin access via AWS SSM Session Manager; no SSH ports open |
| A.8.20 | **Segregation in networks** | Workloads deployed in private subnets; only ALB SG can reach app SG |
| A.8.9  | **Configuration management** | No public IP assigned to EC2; Terraform enforces SG-to-SG rules |
| A.5.19 | **Secure use of cloud services** | ALB as the only internet-facing entry point for the application |

**Risks reduced:**  
- No direct inbound to EC2 from the internet.  
- SSH removed; admin access controlled via IAM policies for SSM.  
- Public attack surface limited to ALB HTTP/HTTPS.

---

## Step 3 — VPC Endpoints + Flow Logs + KMS Encryption
**Security objective:** Keep management/data traffic inside AWS backbone, enable monitoring, and encrypt all data at rest.

| ISO Control | Control Name | Implementation in Terraform |
|-------------|--------------|------------------------------|
| A.8.23 | **Web filtering / network controls** | VPC Interface Endpoints for SSM, EC2Messages, SSMMessages; Gateway Endpoint for S3 |
| A.8.16 | **Monitoring activities** | VPC Flow Logs to encrypted S3 bucket with restricted policy |
| A.8.24 | **Use of cryptography** | EBS and S3 logs encrypted with AWS KMS CMK |
| A.5.19 | **Secure use of cloud services** | Private management traffic via VPC endpoints (no NAT/IGW needed for admin) |
| A.8.15 | **Logging** | Centralized log storage in S3 with access controls and versioning |

**Risks reduced:**  
- No internet route for management/data paths.  
- Network visibility for investigations and compliance audits.  
- Data at rest protected by customer-managed encryption keys.

---

## Summary Table

| Step | Main Security Change | Key ISO/IEC 27001 Controls Addressed |
|------|----------------------|---------------------------------------|
| Step 1 | Public EC2 with least-priv SSH | A.5.15, A.8.20, A.8.9 |
| Step 2 | Private subnets, ALB, SSM only | A.5.18, A.8.20, A.8.9, A.5.19 |
| Step 3 | Endpoints, logging, encryption | A.8.23, A.8.16, A.8.24, A.5.19, A.8.15 |

---

**Note:** This mapping is for demonstration purposes and focuses on controls most directly implemented by this Terraform configuration. In a full ISO/IEC 27001 ISMS, these controls would be supported by documented policies, procedures, and operational monitoring.

