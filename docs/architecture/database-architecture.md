# Managed Database and Data Services Architecture

## Purpose

This document defines the managed database architecture for the Sidiqi AWS Enterprise Cloud Lab. It establishes service-selection criteria, network and security boundaries, credential handling, availability, backup, monitoring, scaling, and recovery expectations for relational and NoSQL workloads.

## Service Selection

### Relational Workloads

Amazon RDS for PostgreSQL is the selected relational database platform.

PostgreSQL is appropriate for application workloads requiring:

- ACID transactions
- relational data models
- referential integrity
- structured queries and joins
- managed backup and recovery
- managed patching and maintenance
- storage encryption
- private VPC connectivity
- integration with AWS Secrets Manager

The lab baseline uses RDS PostgreSQL with encrypted gp3 storage.

### NoSQL Workloads

Amazon DynamoDB is the selected managed NoSQL service for workloads requiring:

- key-value or document access patterns
- low-latency access at scale
- serverless capacity management
- workload-specific partition and sort keys
- managed encryption and recovery capabilities

DynamoDB implementation and representative access patterns are intentionally deferred to DB-003.

## Network Architecture

RDS is deployed into a DB subnet group containing private subnets across multiple Availability Zones.

The database is not publicly accessible.

The intended connectivity path is:

```text
Application Workload
        |
        | TCP/5432
        v
Application Security Group
        |
        v
Database Security Group
        |
        v
Amazon RDS PostgreSQL
The database security group permits PostgreSQL TCP/5432 only from the application security group.

Direct internet access to the database is not permitted.

Connectivity from application instances in both private application subnets has been validated through AWS Systems Manager without requiring SSH access.

Encryption

RDS storage encryption is enabled.

The RDS master-user credential is managed by AWS through AWS Secrets Manager rather than being stored in Terraform source code, variable files, Git, or application configuration.

Secrets Manager protects the managed credential using AWS KMS encryption.

Identity and Credential Strategy

Infrastructure provisioning is performed through the Terraform deployment IAM architecture.

Database credentials must not be committed to source control.

The RDS master credential is AWS-managed through Secrets Manager.

Application workloads should use dedicated application database identities rather than using the database master credential for normal application operations.

Least-privilege access to application credentials will be implemented with the workload-specific database integration.

Availability

The database subnet architecture spans multiple Availability Zones and supports a Multi-AZ RDS deployment.

The DB-001 lab baseline uses a Single-AZ RDS instance for cost control while validating the managed database architecture.

DB-002 owns implementation and validation of the highly available RDS configuration, including Multi-AZ capability where applicable.

Backup and Recovery

Automated RDS backups are enabled.

The current lab account permits a one-day automated backup-retention period under its account-plan restrictions.

Production retention must be selected according to application recovery requirements, organizational policy, and required recovery-point objectives.

DB-004 owns representative backup, restore, connectivity re-establishment, and failure-recovery validation.

Monitoring

The database architecture requires operational monitoring of:

database availability
CPU utilization
database connections
free storage
storage growth
read/write latency
I/O activity
backup health
database events

Amazon RDS metrics and Amazon CloudWatch provide the baseline monitoring integration.

Detailed monitoring implementation belongs to the RDS implementation work in DB-002.

Scaling

The relational database architecture supports:

vertical instance-class scaling
gp3 storage
RDS storage autoscaling
a configured maximum storage threshold
future read replicas where workload requirements justify them
migration to alternative managed relational architectures if future scale requirements demand it

The DB-001 lab baseline starts with 20 GiB of gp3 storage and allows storage autoscaling up to 100 GiB.

DynamoDB capacity and scaling behavior are addressed separately in DB-003.

Failure Recovery Expectations

The architecture separates availability from recovery.

Availability controls reduce service interruption, while backup and restore controls protect against data loss and logical or operational failures.

Expected recovery capabilities include:

automated RDS backups
supported point-in-time recovery within the configured retention window
restoration into controlled private network boundaries
re-establishment of authorized application connectivity
validation of restored database availability and data

DB-004 will exercise and document the representative recovery workflow.

Current DB-001 Validation

The current lab validation confirms:

RDS PostgreSQL is available
database storage is encrypted
the database is not publicly accessible
the DB subnet group uses private VPC subnets
PostgreSQL listens on TCP/5432
application-tier connectivity to TCP/5432 succeeds from both private application instances
the RDS master credential is managed by AWS Secrets Manager
automated backups are enabled
storage autoscaling is configured

The current Single-AZ deployment is a DB-001 architecture baseline and does not satisfy the final high-availability implementation requirements assigned to DB-002.

Implementation Traceability
Requirement	Implementation
Managed relational database	terraform/modules/database/main.tf
Database module inputs	terraform/modules/database/variables.tf
Database module outputs	terraform/modules/database/outputs.tf
Lab database integration	terraform/environments/lab/database.tf
Environment outputs	terraform/environments/lab/outputs.tf
Private DB subnet placement	terraform/modules/network/
Application-to-database security boundary	terraform/modules/network/
Terraform deployment permissions	terraform/modules/iam/policies.tf
Highly available RDS implementation	DB-002 / Issue #32
DynamoDB implementation	DB-003 / Issue #33
Backup and recovery validation	DB-004 / Issue #34
Design Decisions
Use Amazon RDS for PostgreSQL for transactional relational workloads.
Use DynamoDB for representative NoSQL workloads where access patterns justify a key-value or document database.
Keep databases inside private network boundaries.
Restrict PostgreSQL connectivity to authorized application workloads.
Encrypt managed database storage.
Keep database credentials out of source control.
Use AWS Secrets Manager for managed credential storage.
Maintain multi-AZ-capable subnet architecture.
Separate the cost-controlled DB-001 baseline from the highly available DB-002 implementation.
Validate backup and failure recovery separately through DB-004.
