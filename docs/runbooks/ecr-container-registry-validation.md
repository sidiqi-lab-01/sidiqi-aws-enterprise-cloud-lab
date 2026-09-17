# CON-001 — ECR Container Registry Validation

## Objective

Validate the secure Amazon ECR implementation for the enterprise cloud lab.

## Infrastructure Controls

The ECR repository is provisioned through Terraform with:

- AES256 encryption
- Immutable image tags
- Scan-on-push enabled
- Lifecycle policy for untagged and release images
- Least-privilege workload pull permissions
- Terraform-managed configuration

## Lifecycle Policy

The repository implements:

- Untagged images expire after 7 days.
- Tagged release images using the `v` prefix retain the most recent 20 images.

## Representative Image Publication

Representative application images were successfully published to ECR.

### v1.0.0

The initial image was published successfully. ECR scanning could not scan this artifact because Docker produced an OCI image index:

`application/vnd.oci.image.index.v1+json`

ECR returned `UnsupportedImageTypeException`.

The image was retained as troubleshooting evidence.

### v1.0.1

A single-platform Linux AMD64 image was built with provenance disabled and published as `v1.0.1`.

Manifest type:

`application/vnd.oci.image.manifest.v1+json`

The ECR image scan completed successfully.

Scan findings at validation time:

- CRITICAL: 2
- HIGH: 7
- MEDIUM: 1

The findings demonstrate that image scanning is operational. Vulnerability findings require remediation before treating the validation image as production-ready.

## Immutable Tag Validation

A different local image was tagged as the existing `v1.0.1` release and pushed to ECR.

ECR rejected the operation because the tag already existed in an immutable repository.

The image digest before and after the attempted overwrite remained identical.

Result: PASS.

## Least-Privilege Pull Validation

The private application EC2 workload role successfully:

- Retrieved an ECR authorization token.
- Executed `ecr:BatchGetImage`.
- Retrieved the `v1.0.1` image metadata.

Result: PASS.

## Unauthorized Push Validation

The same workload role attempted:

`ecr:InitiateLayerUpload`

AWS returned `AccessDeniedException` because the workload role has no identity-based policy granting the push operation.

Result: PASS.

This demonstrates separation between workload image-consumption permissions and image-publication permissions.

## Terraform Validation

Terraform validation completed successfully.

A final Terraform plan reported:

`No changes. Your infrastructure matches the configuration.`

Result: PASS.

## CON-001 Validation Summary

- ECR repository created through IaC: PASS
- Repository encryption: PASS
- Scan-on-push configuration: PASS
- Representative image publication: PASS
- Successful image vulnerability scan: PASS
- Immutable release tags: PASS
- Lifecycle controls: PASS
- Authorized workload pull: PASS
- Unauthorized workload push denied: PASS
- Terraform reproducibility/no drift: PASS
