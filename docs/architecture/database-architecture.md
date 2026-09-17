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

DB-002 implements and validates the highly available RDS configuration using a Multi-AZ deployment across the private database subnets.

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

DB-002 implements Enhanced Monitoring at a 60-second interval using a dedicated RDS monitoring IAM role.

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

The original Single-AZ deployment was the DB-001 architecture baseline. DB-002 subsequently converted the RDS deployment to Multi-AZ and validated the high-availability configuration.

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

## DB-002 Highly Available RDS Implementation

Issue #32 implements and validates the highly available relational database architecture defined by DB-001.

### High Availability

The lab RDS PostgreSQL deployment is configured as Multi-AZ.

The current validated deployment uses:

- PostgreSQL 18.3
- db.t4g.micro instance class
- gp3 storage
- encrypted storage
- private DB subnet placement
- primary database instance in us-east-1a
- synchronous standby in us-east-1b
- no public database accessibility

Terraform manages the Multi-AZ configuration and applies the lab availability change immediately rather than waiting for the configured maintenance window.

### Network Security

The RDS instance remains accessible only through the database security group.

Application workloads in both private application subnets successfully reached the RDS endpoint over TCP port 5432 after the Multi-AZ conversion.

The database remains non-publicly accessible.

### Credential Management

The RDS master credential continues to use AWS-managed Secrets Manager credential management.

No database password is stored in Terraform source code, Terraform variables, repository configuration, or documentation.

Application workloads should use a dedicated application database identity rather than the RDS master identity.

### Encryption and Secure Parameters

RDS storage encryption is enabled.

The active PostgreSQL 18 default parameter group reports:

- `rds.force_ssl = 1`
- source: `system`
- apply type: `dynamic`

This provides the current database transport-security baseline without duplicating the system setting in a custom parameter group.

### Backup

Automated backups remain enabled with a one-day retention period.

The lab originally attempted a seven-day retention period, but the current AWS account plan rejected that value. The one-day value therefore represents the validated lab constraint rather than the recommended production recovery policy.

Backup restoration and representative recovery testing remain assigned to DB-004.

### Monitoring

RDS Enhanced Monitoring is enabled at a 60-second interval.

A dedicated RDS monitoring IAM role is managed through Terraform and has the AWS-managed `AmazonRDSEnhancedMonitoringRole` policy attached.

Database Insights operates in standard mode.

### Validation Evidence

DB-002 runtime validation confirmed:

- RDS status `available`
- Multi-AZ enabled
- primary Availability Zone `us-east-1a`
- secondary Availability Zone `us-east-1b`
- encrypted storage enabled
- public accessibility disabled
- Enhanced Monitoring interval of 60 seconds
- dedicated monitoring IAM role configured
- `rds.force_ssl = 1`
- successful TCP/5432 connectivity from application instances in both private application subnets
- Terraform convergence with no infrastructure drift

The deployment is reproducible through Terraform and satisfies the DB-002 high-availability, encryption, private-placement, controlled-connectivity, credential-management, backup-configuration, monitoring, and secure-parameter requirements.

## DB-003 DynamoDB Workload and Security Controls

Issue #33 implements and validates the representative DynamoDB workload defined by the DB-001 managed data-services architecture.

### Workload and Access Pattern

The lab uses an application-state DynamoDB table for representative NoSQL workload validation.

The table uses a composite primary key:

- partition key: `entity_id`
- sort key: `record_type`

The validated representative item uses:

- `entity_id = APP#validation`
- `record_type = STATE#current`

This design supports direct item retrieval by composite key and query operations for records associated with a specific entity.

Representative DB-003 operations include:

- `PutItem`
- `GetItem`
- `Query`
- `UpdateItem`
- `DeleteItem`

### Capacity and Scaling

The DynamoDB table uses `PAY_PER_REQUEST` billing mode.

On-demand capacity was selected for the lab because the representative workload is intermittent and does not require fixed provisioned read or write capacity.

This avoids unnecessary capacity provisioning while allowing DynamoDB to manage request capacity for the workload.

Production capacity-mode selection should be based on workload predictability, throughput requirements, cost characteristics, and operational requirements.

### Encryption

DynamoDB server-side encryption is enabled.

AWS validation reports the table encryption status as `ENABLED` with KMS-backed encryption.

No application secrets or database credentials are required for DynamoDB access. Authorization is controlled through IAM.

### Recovery

Point-in-time recovery is enabled for the DynamoDB table.

AWS validation confirms:

- continuous backups enabled
- point-in-time recovery enabled

This provides recovery capability for accidental writes or deletes within the supported DynamoDB recovery window.

Representative restore testing is handled separately by the database recovery workstream.

### Identity and Least-Privilege Access

The EC2 application workload role receives a dedicated DynamoDB IAM policy.

The workload policy permits only the application operations required by the demonstrated access pattern:

- `dynamodb:GetItem`
- `dynamodb:PutItem`
- `dynamodb:UpdateItem`
- `dynamodb:DeleteItem`
- `dynamodb:Query`
- `dynamodb:DescribeTable`

The policy is scoped to the application-state table rather than all DynamoDB resources.

Administrative DynamoDB permissions such as `dynamodb:UpdateTable`, `dynamodb:CreateTable`, and `dynamodb:DeleteTable` are not granted to the application workload role.

Terraform deployment permissions are separate from runtime workload permissions. The Terraform deployment policy contains the infrastructure-management permissions required to create, update, tag, recover, and remove project-scoped DynamoDB tables.

### Security Boundary

DynamoDB authorization is enforced through AWS IAM rather than the RDS-style VPC security-group boundary.

The application workload uses its EC2 IAM role credentials to access the authorized DynamoDB table.

Infrastructure-management permissions remain separate from runtime data-plane permissions.

This separation prevents the application workload from administering the DynamoDB table while allowing its required application data operations.

### Runtime Validation

DB-003 was validated from an application EC2 instance managed by the application Auto Scaling Group and accessed through AWS Systems Manager.

AWS STS confirmed that the runtime commands executed under the EC2 workload role.

The following authorized operations succeeded:

- `PutItem` created the representative application-state item.
- `GetItem` returned the expected item.
- `Query` returned the item using the `entity_id` partition-key access pattern.
- `UpdateItem` changed the item status from `healthy` to `validated`.
- `DeleteItem` removed the validation item and returned the previous values.

The complete authorized validation command completed successfully.

### Negative Authorization Validation

A separate test from the same EC2 workload identity attempted the administrative `dynamodb:UpdateTable` action.

AWS rejected the operation with `AccessDeniedException` because no identity-based policy granted the workload role `dynamodb:UpdateTable`.

This failure is the expected security result and validates the separation between application data-plane permissions and infrastructure-administration permissions.

After the denied operation, validation confirmed that the table remained:

- `ACTIVE`
- `PAY_PER_REQUEST`
- server-side encryption enabled
- point-in-time recovery enabled

### Troubleshooting Evidence

The first runtime validation attempt successfully completed `PutItem` and `GetItem` but stopped during `Query`.

The failure was caused by nested shell and JSON quoting in the SSM Run Command parameters, not by DynamoDB authorization.

The validation procedure was corrected by writing the DynamoDB JSON request parameters to temporary files on the EC2 instance and passing them to the AWS CLI using `file://` references.

The corrected test successfully completed the full authorized `PutItem`, `GetItem`, `Query`, `UpdateItem`, and `DeleteItem` sequence.

This demonstrates the distinction between command-construction failures and IAM authorization failures during operational troubleshooting.

### DB-003 Implementation Traceability

| Requirement | Implementation |
| --- | --- |
| DynamoDB table | `terraform/modules/database/dynamodb.tf` |
| Composite primary key | `entity_id` and `record_type` |
| Capacity mode | `PAY_PER_REQUEST` |
| Server-side encryption | `terraform/modules/database/dynamodb.tf` |
| Point-in-time recovery | `terraform/modules/database/dynamodb.tf` |
| Workload IAM policy | `terraform/environments/lab/dynamodb_access.tf` |
| Workload IAM role | `terraform/modules/iam/` |
| Terraform deployment permissions | `terraform/modules/iam/policies.tf` |
| DynamoDB outputs | `terraform/modules/database/outputs.tf` |
| Environment outputs | `terraform/environments/lab/outputs.tf` |
| Authorized runtime validation | AWS Systems Manager from application EC2 workload |
| Unauthorized operation validation | Denied `dynamodb:UpdateTable` from application workload role |

### DB-003 Design Decisions

- Use DynamoDB for the representative key-value NoSQL workload.
- Use a composite partition-and-sort-key model to demonstrate defined access patterns.
- Use on-demand capacity for the intermittent lab workload.
- Enable server-side encryption.
- Enable point-in-time recovery.
- Separate Terraform infrastructure-management permissions from application runtime permissions.
- Scope application IAM access to the application-state table.
- Do not grant table-administration permissions to the application workload role.
- Validate both successful authorized operations and denied unauthorized operations.
