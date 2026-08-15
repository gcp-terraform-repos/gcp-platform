# artifact-registry

A Docker Artifact Registry repository with a KEEP/DELETE cleanup policy.
Promoted from gcp-keycloak-infrastructure, which used a hardcoded
`keep_versions` cap of 2 to fit inside the 0.5 GB Artifact Registry free
allowance for a ~200 MB image. That number is a fact about one consumer's
image size and budget, not about artifact registries in general, so it
stays a call-site decision (with a wider default range here) rather than a
module-wide constraint.

<!-- BEGIN_TF_DOCS -->
A Docker Artifact Registry repository with a KEEP/DELETE cleanup policy.

Promoted from gcp-keycloak-infrastructure, which used a hardcoded
keep\_versions cap of 2 to fit inside the 0.5 GB Artifact Registry free
allowance for a ~200 MB image. That number is a fact about ONE consumer's
image size and free-tier budget, not about artifact registries in
general, so it stays a call-site decision (default below, with a wider
range) rather than a module-wide constraint.

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0, < 8.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.0, < 8.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_artifact_registry_repository.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for the Artifact Registry repository. Keep it equal to the consuming service's region so image pulls stay in-region. | `string` | n/a | yes |
| <a name="input_repository_id"></a> [repository\_id](#input\_repository\_id) | Artifact Registry repository name. | `string` | n/a | yes |
| <a name="input_cleanup_untagged_after"></a> [cleanup\_untagged\_after](#input\_cleanup\_untagged\_after) | Age at which untagged layers (left behind by rebuilds) are deleted. | `string` | `"3d"` | no |
| <a name="input_description"></a> [description](#input\_description) | Repository description, shown in the console. | `string` | `"Container images"` | no |
| <a name="input_keep_versions"></a> [keep\_versions](#input\_keep\_versions) | Image versions retained by the KEEP cleanup policy. Size this against your free-tier or budget allowance for image size -- e.g. a ~200 MB image against a 0.5 GB allowance caps this at 2. | `number` | `2` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_image_base"></a> [image\_base](#output\_image\_base) | Image path without a tag, e.g. us-east1-docker.pkg.dev/my-project/keycloak. |
| <a name="output_registry_host"></a> [registry\_host](#output\_registry\_host) | Docker registry hostname for this repository's region. |
| <a name="output_repository_id"></a> [repository\_id](#output\_repository\_id) | Artifact Registry repository name. |
<!-- END_TF_DOCS -->
