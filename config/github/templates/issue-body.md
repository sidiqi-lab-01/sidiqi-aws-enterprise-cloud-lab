## Objective

Implement **{{TITLE}}** as part of the **{{MILESTONE}}** engineering phase of the Sidiqi AWS Enterprise Cloud Lab.

## Engineering Context

This work item is part of the enterprise cloud engineering roadmap and must follow the repository's issue-driven development workflow, Infrastructure as Code principles, security standards, documentation requirements, and validation practices.

## Classification

| Attribute | Value |
|---|---|
| Work Item | `{{KEY}}` |
| Priority | `{{PRIORITY}}` |
| Domain | `{{DOMAIN}}` |
| Work Type | `{{WORK_TYPE}}` |
| Phase | `{{PHASE}}` |
| Effort | `{{EFFORT}}` |
| Risk | `{{RISK}}` |
| Environment | `{{ENVIRONMENT}}` |
| Milestone | `{{MILESTONE}}` |

## Engineering Requirements

- Define the technical requirements before implementation.
- Use Infrastructure as Code or reusable automation where applicable.
- Follow repository naming, branching, commit, and documentation standards.
- Use least-privilege and secure-by-default design principles.
- Avoid hardcoded credentials, secrets, account identifiers, or environment-specific sensitive data.
- Make implementation reusable and idempotent where practical.
- Document important design decisions and tradeoffs.

## Security Requirements

- Apply least privilege.
- Encrypt sensitive data where applicable.
- Prevent secrets from entering source control.
- Validate network and identity boundaries where applicable.
- Record security-relevant assumptions and controls.
- Run applicable security validation before merge.

## Validation Requirements

- Validate syntax and configuration.
- Execute applicable automated repository checks.
- Validate the implemented capability against the issue objective.
- Capture meaningful evidence of successful implementation.
- Document failures and troubleshooting when they provide reusable engineering knowledge.

## Documentation Requirements

Update applicable documentation, including:

- implementation commands
- architecture documentation
- operational procedures
- validation evidence
- troubleshooting documentation
- relevant README or runbook content

## Engineering Workflow

1. Create or use the issue-specific feature branch.
2. Implement the required capability.
3. Perform local validation.
4. Perform applicable security validation.
5. Commit using the repository commit standard.
6. Push the feature branch.
7. Open a pull request.
8. Pass GitHub Actions validation.
9. Complete Copilot-assisted review where applicable.
10. Complete human review.
11. Merge the pull request.
12. Close the issue.
13. Retain the merged feature branch for historical and portfolio traceability.

## Acceptance Criteria

- [ ] Technical requirements are defined.
- [ ] Implementation satisfies the objective.
- [ ] Automation/IaC is used where applicable.
- [ ] Security controls are implemented and validated.
- [ ] Repository validation passes.
- [ ] Documentation is updated.
- [ ] Troubleshooting evidence is captured where applicable.
- [ ] Pull request review is completed.
- [ ] Implementation is merged successfully.
- [ ] Final validation evidence is recorded.

## Traceability

Project work item: `{{KEY}}`

Generated from the repository-managed GitHub project configuration.
