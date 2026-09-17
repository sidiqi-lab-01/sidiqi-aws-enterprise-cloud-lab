# Database Backup and Recovery Runbook

## Purpose

This runbook defines backup, restore, and failure-recovery procedures for the managed database services in the Sidiqi AWS Enterprise Cloud Lab.

Work item: DB-004 / Issue #34.

## Recovery Requirements

The recovery design must:

- preserve the active source database during recovery testing
- use encrypted backup or point-in-time recovery capabilities
- restore into a separate recovery resource where supported
- preserve private network and identity boundaries
- validate recovered data before considering recovery successful
- validate connectivity after recovery
- capture recovery timing and troubleshooting evidence
- avoid exposing database credentials or secrets

## RDS PostgreSQL Recovery

The managed PostgreSQL database uses automated RDS backups.

Validated source controls include:

- PostgreSQL 18.3
- Multi-AZ deployment
- private accessibility
- encrypted storage
- automated backups enabled
- one-day backup retention under the current lab account-plan restriction
- encrypted automated snapshots
- an active point-in-time recovery window

### Intended Restore Procedure

The recovery procedure restores an available automated snapshot into a separate RDS instance using:

- the existing private DB subnet group
- the existing database security group
- no public accessibility
- encrypted source backup
- a separate recovery database identifier

The production-like lab source database must remain unchanged during the recovery operation.

### RDS Restore Validation Attempt

DB-004 attempted an actual restore from an available encrypted automated RDS snapshot into a separate recovery instance.

The restore request was rejected by AWS with:

`InstanceQuotaExceeded`

AWS reported that the maximum number of instances available to the account's free plan had been reached.

Post-failure validation confirmed:

- no recovery RDS instance was created
- the source PostgreSQL database remained available
- the source remained Multi-AZ
- public accessibility remained disabled
- storage encryption remained enabled
- the automated recovery snapshot remained available and encrypted

The standard RDS service quota was not the blocking control. The failure was caused by the account-plan-specific instance restriction.

No existing database was deleted or modified to bypass the restriction.

### RDS Recovery Status

Backup readiness: validated.

Encrypted recovery artifact: validated.

Restore procedure: exercised.

Separate-instance restore: blocked by account-plan quota.

Recovered RDS data validation: pending a successful separate-instance restore.

Application connectivity to restored RDS: pending a successful separate-instance restore.

## DynamoDB Recovery

The application-state DynamoDB table has continuous backups and point-in-time recovery enabled.

Validated controls include:

- table status ACTIVE
- PAY_PER_REQUEST capacity mode
- server-side encryption enabled
- continuous backups enabled
- point-in-time recovery enabled
- valid earliest and latest restore timestamps

### Recovery Validation Record

A non-sensitive DB-004 recovery-validation item was written to the source table and read back successfully.

The record uses the existing application-state access pattern:

- partition key: `APP#db004-recovery`
- sort key: `STATE#recovery-test`
- status: `recover-me`
- work item: `DB-004`

A safe point-in-time recovery timestamp was observed after the validation record had been written and verified.

The source validation record was intentionally retained. No destructive data-loss simulation was performed.

### DynamoDB Recovery Procedure

A full recovery exercise can restore the source table to a separate target table using DynamoDB point-in-time recovery.

The recovery target must use a distinct table name so that the source table remains unchanged.

After the restored table becomes ACTIVE, validation should confirm:

1. the recovery table exists
2. encryption remains enabled
3. the expected key schema is present
4. the DB-004 validation record is present
5. the recovered values match the expected pre-recovery values
6. authorized connectivity and data access can be re-established
7. recovery timing is recorded

### DynamoDB Recovery Status

Continuous backups: validated.

PITR: validated.

Recovery window: validated.

Known validation data: created and verified.

Safe restore point: validated.

Destructive source-data simulation: intentionally not performed.

Separate recovery-table restore: pending.

## Troubleshooting Evidence

### RDS InstanceQuotaExceeded

An RDS automated-snapshot restore was attempted into a separate private recovery instance.

AWS rejected the operation because the account's free-plan instance allowance had been reached.

The failed operation created no recovery instance and did not modify the source database.

The engineering response was to preserve the source database and recovery artifact rather than delete healthy infrastructure merely to bypass a lab account restriction.

## Recovery Completion Criteria

DB-004 is fully complete when a representative restore succeeds and the following evidence is captured:

- backup artifact or PITR source verified
- separate recovery resource created successfully
- restored data validated
- authorized connectivity re-established
- encryption and security boundaries validated
- recovery timing recorded
- Terraform and repository validation completed
- recovery evidence documented

Until a representative restore succeeds, DB-004 remains partially validated rather than claiming full recovery completion.
