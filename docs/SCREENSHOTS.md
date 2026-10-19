# Screenshot Evidence Checklist

Save screenshots under `docs/screenshots/`. Do not include access keys, passwords, secret values, session tokens or other credentials.

## Milestone 1
- [ ] `terraform init` success
- [ ] `terraform validate` success
- [ ] GitHub repository with project skeleton
- [ ] Remote state bucket configuration (show bucket name only if safe)

## Milestone 2
- [ ] `terraform plan -var-file=dev.tfvars` summary
- [ ] VPC and subnet view across two AZs
- [ ] Network diagram showing public/private/database tiers and NAT routes

## Milestone 3
- [ ] Security group inbound/outbound rules for ALB, app and DB
- [ ] Show app port only from ALB SG and DB 3306 only from app SG

## Milestone 4
- [ ] ALB DNS page showing environment, hostname and AZ
- [ ] Session Manager connected to an app instance
- [ ] ASG replacement after terminating one instance
- [ ] CPU metric and scaling activity during load test

## Milestone 5
- [ ] RDS overview showing private access, encryption and Multi-AZ setting
- [ ] Secret metadata/ARN only; never reveal secret value
- [ ] S3 versioning, encryption and public access block
- [ ] Insecure HTTP request denied (ensure no secret data in terminal output)

## Milestone 6
- [ ] Dev/prod tfvars values with no secrets
- [ ] Production plan summary (do not apply production unless approved)
- [ ] Final README and ANSWERS.md in GitHub
- [ ] `terraform destroy` completion for temporary resources
- [ ] 2–3 minute demo video
