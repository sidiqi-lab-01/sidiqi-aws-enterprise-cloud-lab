# AWS Identity and Access Management Architecture

## 1. Objective

Define the enterprise identity and access management architecture for the
Sidiqi AWS Enterprise Cloud Lab.

This architecture establishes secure access patterns for human users,
administrative access, automation, and AWS workloads while applying
least-privilege, role-based access control, separation of responsibilities,
and auditable privilege elevation.

This document supports GitHub Issue #11 and project work item `IAM-001`.

## 2. Requirements

The IAM architecture must:

- Separate human identities from workload identities.
- Separate routine engineering access from administrative access.
- Minimize persistent privileged access.
- Prefer temporary credentials over long-lived credentials.
- Use IAM roles for AWS workloads where supported.
- Apply least-privilege permissions.
- Define explicit trust relationships.
- Support controlled privilege elevation.
- Maintain auditable authentication and authorization paths.
- Prevent credentials and secrets from being stored in source control.
- Support Infrastructure as Code for IAM implementation.
- Provide reusable patterns for future AWS services and Kubernetes workloads.

## 3. Architecture

The identity architecture uses separate access paths for human users,
administrative operations, automation, and workloads.

### Human Engineering Access

```text
Human Engineer
      |
      v
Authentication
      |
      v
Engineering Access
      |
      v
Authorized IAM Role
      |
      v
Least-Privilege AWS Permissions
```
Human engineers receive only the permissions required for normal engineering
activities.

Administrative privileges are not part of the normal engineering access path.

### Administrative Access

```text
Authorized Administrator
        |
        v
Authentication
        |
        v
Normal Engineering Identity
        |
        v
Controlled Role Assumption
        |
        v
Administrative IAM Role
        |
        v
Elevated AWS Permissions
```
Administrative access requires an intentional privilege-elevation action.

The design minimizes standing administrative privilege and creates a distinct
authorization boundary between routine engineering work and privileged
operations.

### Workload Access

```text
AWS Workload
     |
     v
Service / Workload Identity
     |
     v
IAM Role
     |
     v
Scoped AWS Permissions
     |
     v
Required AWS Service
```

AWS workloads use roles and temporary credentials where supported instead of
embedded long-lived access keys.

### Automation Access

```text
Approved Automation
       |
       v
Authenticated Execution Environment
       |
       v
Automation / Deployment Role
       |
       v
Scoped Deployment Permissions
       |
       v
AWS Resources
```

Infrastructure automation receives permissions through dedicated roles rather
than sharing human administrative identities.

4. Identity Types

The architecture defines four primary identity categories.

Identity Type	Purpose	Credential Model	Privilege Model
Human engineering identity	Routine engineering operations	Temporary credentials preferred	Least privilege
Administrative identity/role	Privileged administrative operations	Controlled role assumption	Elevated, intentionally assumed
Automation identity	Terraform and approved automation	Role-based temporary credentials	Deployment-specific
Workload identity	EC2, Kubernetes, and AWS services	Service/workload roles	Application-specific

These identities must not be treated as interchangeable.

5. Trust Boundaries

The primary IAM trust boundaries are:

```text
Human Identity
      |
      | Authentication boundary
      v
Engineering Role
      |
      | Privilege-elevation boundary
      v
Administrative Role


Automation Environment
      |
      | Role-assumption boundary
      v
Deployment Role


AWS Workload
      |
      | Service trust boundary
      v
Workload Role
      |
      | Authorization boundary
      v
AWS Service
```

Crossing a trust boundary requires an explicitly authorized authentication or
role-assumption mechanism.

6. Separation of Responsibilities

The architecture separates:

Human access from machine access.
Engineering permissions from administrative permissions.
Deployment permissions from workload runtime permissions.
Authentication from authorization.
Role trust policies from role permission policies.
Infrastructure deployment responsibilities from application runtime access.

A workload role must not be reused as a human administrative role.

A Terraform deployment role must not automatically provide unrestricted
administrative access.

7. Least-Privilege Model

Permissions are granted according to the minimum actions and resources required
for a defined responsibility.

IAM policies should:

Prefer explicitly required actions.
Scope resources where AWS services support resource-level permissions.
Avoid wildcard actions and resources unless technically necessary.
Document justified exceptions.
Separate trust policy configuration from permission policy configuration.
Be reviewed as responsibilities change.
Support automated policy and security validation where practical.
8. Authentication Expectations

Human access should use centrally managed authentication and temporary AWS
credentials where practical.

The architecture does not rely on repository-stored AWS access keys.

Workloads and automation should obtain temporary credentials from IAM roles or
other approved AWS identity mechanisms where supported.

Multi-factor authentication should protect privileged human access where
supported by the selected authentication architecture.

9. Privilege Elevation

Routine engineering access and administrative access are separate.

Administrative operations should require deliberate role assumption rather than
providing persistent administrative permissions to the normal engineering
identity.

Future implementation must validate:

Authorized role assumption succeeds.
Unauthorized role assumption fails.
Administrative actions require the appropriate elevated role.
Routine identities cannot perform unauthorized administrative operations.
Role-assumption activity can be audited.
10. Workload Identity

AWS workloads should use service-specific or workload-specific IAM roles.

Examples include:

EC2 instance roles.
Kubernetes workload identity mechanisms.
AWS service roles.
CI/CD or infrastructure deployment roles.

Long-lived AWS credentials must not be embedded in:

application source code
shell scripts
Terraform configuration
container images
Kubernetes manifests
repository configuration
11. Current Lab Authentication

The current engineering host authenticates to AWS through an EC2 IAM role and
temporary credentials supplied through the EC2 instance metadata credential
mechanism.

The AWS CLI default region for this project is:

us-east-1

The project does not require locally configured long-lived AWS access keys for
the current EC2-based engineering workflow.

Account identifiers and temporary credential values are intentionally excluded
from repository documentation.

12. Infrastructure as Code Strategy

IAM resources created in subsequent implementation work should be managed
through Terraform where practical.

Expected reusable components include:

IAM roles
role trust policies
permission policies
policy attachments
permission boundaries where required
workload roles
deployment roles

Terraform implementation must be validated before deployment and reviewed
through the repository pull-request workflow.

13. Security Controls

The IAM baseline includes the following design controls:

Least privilege.
Separation of human and workload identities.
Separation of normal and privileged access.
Temporary credentials where supported.
Controlled role assumption.
Explicit trust relationships.
No hardcoded credentials.
No secrets committed to Git.
Auditable access paths.
Infrastructure as Code review.
Authorization failure testing.
Policy validation and access analysis.
14. Design Decisions
Role-Based Access

IAM roles are preferred over distributing persistent IAM user credentials.

Separate Administrative Access

Administrative permissions are separated from normal engineering permissions
to reduce standing privilege.

Separate Workload Roles

Workloads receive dedicated identities so application permissions can be
independently controlled and audited.

Infrastructure as Code

IAM configuration will be implemented through Terraform where applicable to
provide repeatability, reviewability, version control, and traceability.

Regional Standard

Regional AWS resources for this lab are standardized on:

us-east-1

IAM is primarily an AWS global service, but workloads consuming IAM roles may
operate in the project's designated region.

15. Validation Strategy

Future IAM implementation will validate both successful and denied access.

Validation will include:

AWS identity verification.
Role trust-policy validation.
Authorized role-assumption testing.
Unauthorized role-assumption testing.
Least-privilege permission testing.
IAM policy/security analysis.
Terraform validation.
Repository security validation.
Pull-request review evidence.
16. Cost Considerations

IAM roles and policies do not normally introduce direct resource usage charges.

Services used later for logging, security analysis, monitoring, credential
management, or related controls may introduce costs and must be evaluated
separately.

17. Monitoring and Audit

IAM-related activity should be observable through applicable AWS auditing and
logging capabilities implemented in later project phases.

Security-relevant events include:

authentication activity
role assumption
privileged operations
authorization failures
IAM policy changes
trust-policy changes
18. Troubleshooting

IAM troubleshooting should distinguish authentication failures from
authorization failures.

The general diagnostic process is:

```text
Identify caller
      |
      v
Verify authentication
      |
      v
Inspect role trust relationship
      |
      v
Inspect identity permissions
      |
      v
Inspect applicable boundaries/controls
      |
      v
Reproduce permitted or denied action
      |
      v
Capture sanitized evidence
```

Useful IAM failures discovered during implementation will be documented under
docs/troubleshooting/.

19. Rollback

IAM changes implemented in subsequent work must have a documented rollback
strategy.

Rollback must avoid removing access required to recover or safely administer
the environment.

High-impact IAM changes should be validated before existing known-good access
paths are removed.

20. Cleanup

Temporary test identities, policies, role assignments, and validation resources
must be removed when they are no longer required.

Production-like IAM architecture documentation should remain in source control
as engineering evidence.

21. Implementation Traceability

This architecture establishes requirements for subsequent IAM implementation
work.

```text
IAM-001
Identity architecture and security baseline
        |
        +--> IAM role implementation
        |
        +--> Administrative privilege elevation
        |
        +--> Workload identities
        |
        +--> IAM policy validation
        |
        +--> Access failure testing
```

Implementation must remain traceable from requirement to GitHub issue,
feature branch, code, validation evidence, pull request, and merge.

22. Lessons Learned

Lessons learned will be updated as IAM controls are implemented and validated
through subsequent project work.
