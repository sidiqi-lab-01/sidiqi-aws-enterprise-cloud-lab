# Sidiqi AWS Enterprise Cloud Lab

## Purpose

This project manages the engineering roadmap for an enterprise AWS cloud, DevSecOps, Kubernetes, security, automation, observability, disaster recovery, and FinOps portfolio environment.

## Engineering Model

Work follows an issue-driven engineering lifecycle:

Requirement
→ GitHub Issue
→ Feature Branch
→ Implementation
→ Local Validation
→ Security Validation
→ Commit
→ Push
→ Pull Request
→ GitHub Actions
→ Copilot Review
→ Human Review
→ Merge
→ Close Issue
→ Retain Feature Branch

## Project Principles

- Infrastructure as Code first
- Automation over repetitive manual operations
- Security by design
- Least privilege
- Reusable engineering patterns
- Documented commands and troubleshooting
- Evidence-based validation
- Pull-request-driven changes
- Human review remains part of the engineering lifecycle
- Merged feature branches are retained for historical and portfolio traceability

## Major Engineering Domains

- Project governance
- AWS governance and IAM
- Enterprise networking
- Compute and storage
- Databases and data services
- Containers and Kubernetes
- Serverless and integration
- DevSecOps and GitOps
- Security and compliance
- Observability and operations
- Backup and disaster recovery
- FinOps and optimization
- Enterprise integration
- Portfolio validation

## Automation

Project configuration is maintained under:

- `config/github/`
- `scripts/github/`

Where supported, GitHub project-management resources are reconciled through reusable and idempotent automation.
