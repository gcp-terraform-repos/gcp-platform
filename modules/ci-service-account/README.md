# ci-service-account

A CI service account, in the CONSUMING repo's own GCP project, that
authenticates via the shared WIF pool but is impersonable only by that
repo's GitHub Actions workflows. Never touches the hub project --
`wif_pool_name` is consumed as an opaque string.

<!-- BEGIN_TF_DOCS -->
A CI service account, in the CONSUMING repo's own GCP project, that
authenticates via the shared WIF pool but is impersonable only by that
repo's GitHub Actions workflows.

This module never touches the hub project: var.wif\_pool\_name is just a
string (the pool's resource name) used to build a principalSet member on a
binding that lives on THIS service account, in THIS project. No permission
on the hub project is required to call this module.

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
| [google_project_iam_member.ci](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.ci](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Service account ID, e.g. keycloak-ci. Must be unique within project\_id. | `string` | n/a | yes |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Human-readable name for the service account. | `string` | n/a | yes |
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | The consuming repo's name, without the owner prefix. This is what scopes impersonation to exactly this repo. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project the CI service account lives in -- the consuming repo's own project, not the hub. | `string` | n/a | yes |
| <a name="input_wif_pool_name"></a> [wif\_pool\_name](#input\_wif\_pool\_name) | Full resource name of the shared pool, from gcp-platform bootstrap's wif\_pool\_name output. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | What this account does; shown in the GCP console. | `string` | `"Runs CI/CD from GitHub Actions via Workload Identity Federation"` | no |
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | GitHub org the consuming repo lives under. | `string` | `"gcp-terraform-repos"` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | Project-level IAM roles to grant the CI service account. Defaults to none: an identity that can authenticate but do nothing is the safe default. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_member"></a> [member](#output\_member) | Ready-made IAM member string, "serviceAccount:<email>". Saves every caller re-interpolating the prefix. |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Email of the created CI service account. Set as the GitHub Actions variable CI\_SERVICE\_ACCOUNT. |
| <a name="output_service_account_id"></a> [service\_account\_id](#output\_service\_account\_id) | The short account\_id, e.g. keycloak-ci. |
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | Fully-qualified name, projects/<p>/serviceAccounts/<email>. Use as service\_account\_id in further IAM bindings. |
| <a name="output_unique_id"></a> [unique\_id](#output\_unique\_id) | Numeric unique ID. Stable across a delete/recreate of the same email; use it when an audit log or a deleted:serviceAccount: member must be matched. |
| <a name="output_wif_principal_set"></a> [wif\_principal\_set](#output\_wif\_principal\_set) | The principalSet:// member this SA trusts. Exported for audit -- this string IS the access boundary. |
<!-- END_TF_DOCS -->
