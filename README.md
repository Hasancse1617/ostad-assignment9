# NovaCart — Operation Zero Downtime

Terraform capstone: reusable AWS 3-tier architecture for dev and prod.

## Architecture

```text
Internet
   |
Internet-facing Application Load Balancer (public subnet AZ-a + AZ-b)
   |
   +--> Auto Scaling Group: Amazon Linux + nginx (private subnet AZ-a)
   +--> Auto Scaling Group: Amazon Linux + nginx (private subnet AZ-b)
                         |
                         +--> RDS MySQL (database subnets, private)
                         +--> Private S3 assets bucket (HTTPS-only policy)

Private app subnet outbound: NAT Gateway -> Internet Gateway
Database subnets: no default internet route
Admin access: AWS Systems Manager Session Manager (no SSH key required)
```

## Requirements
- Terraform >= 1.5 (prefer current stable release)
- AWS CLI v2, Git, AWS account and non-root IAM identity
- AWS permissions for VPC, EC2, ELB, Auto Scaling, IAM, RDS, S3, Secrets Manager and SSM
- Default region: `ap-southeast-1` (Singapore)

## 1. Configure AWS credentials
Use an IAM role/profile or `aws configure` with a dedicated IAM user. Never use root credentials or commit credentials.

```bash
aws sts get-caller-identity
aws configure
```

The account identity command should show the expected AWS account and IAM identity.

## 2. Create remote state bucket (recommended for team use)
Create a globally unique S3 bucket manually before enabling the backend. Enable bucket versioning, default encryption, and block public access. Then edit `backend.tf`, set a unique bucket name and environment-specific key, and uncomment the backend block.

```bash
terraform init
# After enabling backend configuration:
terraform init -migrate-state
```

For a separate environment state, use a distinct key such as `novacart/dev/terraform.tfstate` and `novacart/prod/terraform.tfstate`. Backend configuration cannot use ordinary Terraform input variables. Do not store state bucket contents in the application assets bucket.

## 3. Prepare project

Suggested repository name: `ostad-assignment9`. Create an empty public GitHub repository, then push this project:
```bash
git init -b main
git add .
git commit -m "chore: scaffold Terraform 3-tier project"
git remote add origin https://github.com/YOUR-USERNAME/ostad-assignment9.git
git push -u origin main
```

Commit each milestone separately and tag the commit that completes it. Example after the Milestone 1 commit:
```bash
git tag -a m1 -m "Milestone 1: Foundation and remote state"
git push origin m1
```
Repeat for `m2` through `m6` only after each corresponding milestone commit. Do not tag all six milestones at the same final commit.

## 3. Prepare project
```bash
git clone https://github.com/YOUR-USERNAME/ostad-assignment9.git
cd ostad-assignment9
cp terraform.tfvars.example dev.tfvars
# Edit owner and other values in dev.tfvars
terraform fmt -recursive
terraform init
terraform validate
```

`dev.tfvars` and `prod.tfvars` are intentionally git-ignored because they are environment-specific inputs. If your course requires them in Git, use sanitized example files with no secrets and review the policy first.

## 4. Deploy dev
```bash
terraform plan -var-file=dev.tfvars -out=dev.tfplan
terraform apply dev.tfplan
terraform output
```
Open `http://$(terraform output -raw alb_dns_name)` in a browser. Refresh several times. The page shows the hostname, Availability Zone and environment; load-balancer routing may repeatedly choose the same healthy target.

## 5. Verify behavior
```bash
ALB_DNS="$(terraform output -raw alb_dns_name)"
curl -i "http://${ALB_DNS}/"
aws autoscaling describe-auto-scaling-groups --region ap-southeast-1
aws elbv2 describe-target-health --target-group-arn "$(terraform output -raw target_group_arn)"
```

The root module exports `target_group_arn` for this check.

### Session Manager
In AWS Console: EC2 → Instances → select an app instance → Connect → Session Manager.
Alternatively, use AWS CLI after installing the Session Manager plugin:
```bash
aws ssm start-session --target i-REPLACE_INSTANCE_ID --region ap-southeast-1
```

The app instance role is granted `secretsmanager:GetSecretValue` only for the RDS-managed secret ARN. From a Session Manager shell, install a MySQL client if needed and retrieve the secret (do not paste the output into screenshots or logs):
```bash
sudo dnf install -y mariadb105
SECRET_ARN="REPLACE_WITH_TERRAFORM_OUTPUT_SECRET_ARN"
aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --query SecretString --output text
```
The returned JSON contains the username/password. Keep it private; use a secure shell variable or approved secret-handling procedure rather than saving it in shell history. The database security group accepts TCP 3306 only from the app security group.
The app instance needs an instance profile with `AmazonSSMManagedInstanceCore` and network access to SSM endpoints. This baseline uses NAT for outbound connectivity; a more private production design can use SSM interface VPC endpoints.

### Chaos drill
1. Find an ASG instance in EC2.
2. Terminate it.
3. Wait for ASG to launch a replacement and for the ALB target to become healthy.
4. Save screenshots of the old instance termination, replacement instance and target health.

### CPU scaling drill
Use Session Manager to connect to an app instance and run a temporary load generator only if it is available from trusted repositories and permitted by your environment. Example with `stress-ng`:
```bash
sudo dnf install -y stress-ng
stress-ng --cpu 2 --timeout 300s
```
Watch EC2 CPU metrics and Auto Scaling Activity. Small instances may not sustain high load. Remove the load after the test.

## 6. Plan prod (do not apply for coursework unless explicitly authorized)
```bash
terraform plan -var-file=prod.tfvars -out=prod.tfplan
terraform show prod.tfplan
```
Production enables one NAT Gateway per AZ, RDS Multi-AZ, deletion protection, final snapshot, two minimum app instances and a larger maximum fleet. Review costs and the plan before any apply.

## 7. HTTPS side quest
Set `enable_https = true` and `acm_certificate_arn` to an ACM certificate for a domain you control in the same region as the ALB. Add DNS validation and a Route 53 record if desired. The ALB redirects HTTP to HTTPS. Do not enable without a valid certificate ARN.

## 8. Formatting and validation
```bash
terraform fmt -recursive
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```
`terraform validate` checks syntax/provider schemas, not cloud quotas, IAM permission, cost, or every runtime behavior. Always inspect `terraform plan`.

## 9. Destroy to avoid costs
For dev resources:
```bash
terraform destroy -var-file=dev.tfvars
```
If RDS deletion protection is enabled, disable it via an approved change before destroy. Confirm final snapshots and S3 object/version retention before teardown. The S3 bucket uses `force_destroy = false`, so empty it (including object versions) before destroy. Do not delete the remote state bucket while it is still needed.

## Cost notes
The assignment warns NAT Gateway, ALB and RDS can cost roughly USD 2–3/day even with dev defaults; actual charges vary by region, traffic, data processing, storage, backups and current AWS pricing. Prod with multi-AZ RDS and two NAT Gateways costs more. Use AWS Pricing Calculator, set a budget alert, and destroy temporary resources after testing.

## Deliverables checklist
- [ ] Six milestones committed and tagged `m1` ... `m6`
- [ ] `terraform fmt -check -recursive` passes
- [ ] `terraform validate` passes
- [ ] `terraform plan -var-file=dev.tfvars` reviewed
- [ ] `terraform plan -var-file=prod.tfvars` reviewed (no prod apply required)
- [ ] Screenshots in `docs/`
- [ ] Design review answers in `ANSWERS.md`
- [ ] 2–3 minute launch demo recorded
- [ ] Temporary infrastructure destroyed
