# Design Review Answers — NovaCart

## Milestone 1 — Foundation & remote state

### Why is remote state with locking important in a team?
Terraform state maps configuration to real resources. A shared remote backend gives the team one current state, access control, encryption, versioning and recovery options. Locking serializes operations so two engineers do not write conflicting state updates at the same time.

### What if two engineers run `terraform apply` without locking?
Both may read the same old state and attempt changes concurrently. This can cause conflicting operations, stale state, failed applies, duplicate resources or state corruption. Coordinate changes and use a backend with locking.

## Milestone 2 — VPC

### Why do app servers live in private subnets but still reach the internet?
Private instances have no direct route from the public internet. Their route table sends outbound internet traffic through a NAT Gateway in a public subnet. Internet-initiated connections cannot directly reach the app instances through that NAT route. Security groups further restrict traffic.

### Single NAT versus one NAT per AZ?
One NAT is cheaper but creates an AZ dependency and cross-AZ data charges; if its AZ fails, private instances relying on it may lose outbound access. One NAT per AZ costs more but improves AZ-level resilience and keeps outbound paths local.

## Milestone 3 — Security Groups

### Why is a security group reference safer than a CIDR?
A security-group reference expresses trust in network interfaces associated with that group, rather than trusting every host in a broad IP range. It is more precise and adapts as instances change IP addresses. It does not replace IAM or application-level security.

### If the ALB is compromised, what can an attacker reach directly?
The rules allow the ALB security group to reach the app tier on the app port. The app tier can reach MySQL on 3306. The ALB has no direct rule to the database, so it cannot directly connect to the DB under these rules. A compromised app instance may still be able to reach the DB; least privilege and app hardening remain important.

## Milestone 4 — ALB & Auto Scaling

### What attack does IMDSv2 help protect against?
IMDSv2 uses a session-oriented token flow, helping mitigate certain Server-Side Request Forgery (SSRF) and open-proxy paths that could otherwise be abused to query EC2 instance metadata and steal temporary credentials. It is defense in depth, not a guarantee against every SSRF.

### What happens when user data changes and instance refresh is enabled?
A user-data change alters the launch template version. The ASG instance-refresh trigger can roll out replacement instances using the updated template, subject to refresh settings and health checks. User data normally runs at first boot, so changing it does not automatically rerun on existing instances without replacement.

## Milestone 5 — RDS & S3

### Why use RDS-managed Secrets Manager passwords instead of a Terraform variable?
A password variable can appear in shell history, CI logs, plan files or Terraform state. With RDS-managed master credentials, RDS generates and rotates the master password in Secrets Manager, and Terraform outputs only the secret ARN. IAM should tightly control who can read the secret.

### What does Multi-AZ protect against, and what does it not protect against?
RDS Multi-AZ provides a standby in another Availability Zone and supports failover for certain AZ/instance failures. It is not a read-scaling feature for a standard Multi-AZ DB instance, and it does not protect against bad queries, accidental deletion, application bugs, credential compromise or region-wide failure. Backups and recovery planning are still needed.

## Milestone 6 — Environments & production readiness

### Workspaces vs separate state keys/directories: what for production?
For production, separate state keys and ideally separate AWS accounts/roles per environment provide clearer access boundaries, independent permissions, and lower risk of accidentally operating on the wrong environment. Workspaces share the same backend configuration and access boundary, so they are useful for lightweight isolation but not a strong security boundary.

### Which three resources drive most of the cost, and how reduce them?
The assignment specifically warns that NAT Gateways, ALB and RDS can be major costs in dev. Use one NAT in dev, small RDS/EC2 classes, minimal ASG capacity, short-lived test environments, budgets/alerts, and destroy infrastructure after sessions. For production, do not remove redundancy solely to save money without assessing the availability requirement.
