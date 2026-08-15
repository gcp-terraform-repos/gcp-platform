# new-repo-bootstrap example

A complete, runnable example of a new repo's `bootstrap/` consuming
`gcp-platform`. Copy `main.tf` (and adjust `activate_apis` / `ci_roles`) into
the new repo's own `bootstrap/`, swap the relative `source` for the pinned
`git::` form shown in the comment, and fill in `terraform.tfvars` from
`terraform.tfvars.example`.

This directory is validated (`init -backend=false && validate`) by
gcp-platform's own CI on every PR, so it stays proven coherent with the
modules it demonstrates -- it is not `tofu apply`-able as-is without a real
project and (for Option A) values from an already-applied `gcp-platform`
hub.

See [`../../CLAUDE.md`](../../CLAUDE.md#how-a-new-repo-consumes-this) for the
full onboarding writeup, including the trade-off between the two WIF
resolution options shown here.

<!-- BEGIN_TF_DOCS -->
A complete, runnable example of a new repo's bootstrap/ consuming
gcp-platform. Copy this into the new repo's own bootstrap/ and adjust
activate\_apis / ci\_roles to what that repo's CI actually needs.

This file is validated (init -backend=false && validate) by gcp-platform's
own CI on every PR, so it cannot silently drift out of sync with the
modules it demonstrates.

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0, < 8.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | ../../modules/repo-bootstrap | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | The new repo's name, without the owner prefix. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The new repo's own GCP project -- not the hub. | `string` | n/a | yes |
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | GitHub org the new repo lives under. | `string` | `"gcp-terraform-repos"` | no |
| <a name="input_hub_project_id"></a> [hub\_project\_id](#input\_hub\_project\_id) | gcp-platform hub project ID. Only used if you switch main.tf to Option B. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region for the new repo's state bucket. | `string` | `"us-east1"` | no |
| <a name="input_wif_pool_name"></a> [wif\_pool\_name](#input\_wif\_pool\_name) | gcp-platform bootstrap's wif\_pool\_name output. | `string` | `null` | no |
| <a name="input_wif_provider_name"></a> [wif\_provider\_name](#input\_wif\_provider\_name) | gcp-platform bootstrap's wif\_provider\_name output. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_ci_service_account_email"></a> [ci\_service\_account\_email](#output\_ci\_service\_account\_email) | n/a |
| <a name="output_github_variables_command"></a> [github\_variables\_command](#output\_github\_variables\_command) | n/a |
| <a name="output_state_bucket"></a> [state\_bucket](#output\_state\_bucket) | n/a |
<!-- END_TF_DOCS -->
