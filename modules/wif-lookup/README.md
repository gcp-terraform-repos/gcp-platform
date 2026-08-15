# wif-lookup

Resolves the shared WIF pool + provider resource names, either by a
data-source lookup (`hub_project_id`, needs `roles/iam.workloadIdentityPoolViewer`
on the hub project) or by string passthrough (`wif_pool_name` /
`wif_provider_name`, needs no permission on the hub at all).

The string-passthrough path is not a deprecated fallback -- it is the
permanently supported option for operators who cannot be granted hub read,
or who need to plan while the hub is unreachable. Neither path is "the"
way; pick per-repo. See the root [CLAUDE.md](../../CLAUDE.md#two-ways-to-resolve-the-wif-pool)
for the full trade-off writeup.

<!-- BEGIN_TF_DOCS -->
Resolves the shared WIF pool + provider resource names, via either of two
mutually exclusive paths:

  1. hub\_project\_id set -> look them up with data sources. Requires
     roles/iam.workloadIdentityPoolViewer (BETA-stage role) on the hub
     project for whoever runs the apply.
  2. wif\_pool\_name / wif\_provider\_name set -> pass the strings through
     as-is. Requires NO permission on the hub project at all.

Path 2 is not a deprecated fallback -- it is the permanently supported
option for operators who cannot be granted hub read, or who need to plan
while the hub is unreachable. gcp-platform's ci-service-account module
documents the same "no hub permission needed" property; this module lets a
caller trade that property away deliberately, not by default.

The data sources are real (verified present across the whole
hashicorp/google >= 6.0, < 8.0 range this repo targets), despite the
registry docs' stale "this resource is in beta" banner -- they ship in the
GA provider.

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
| [google_iam_workload_identity_pool.github](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_workload_identity_pool) | data source |
| [google_iam_workload_identity_pool_provider.github](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_workload_identity_pool_provider) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_hub_project_id"></a> [hub\_project\_id](#input\_hub\_project\_id) | Project ID of the gcp-platform identity hub. When set, the pool and<br/>provider are looked up by data source, which requires<br/>roles/iam.workloadIdentityPoolViewer on this project for whoever runs the<br/>apply. Mutually exclusive with wif\_pool\_name/wif\_provider\_name. | `string` | `null` | no |
| <a name="input_wif_pool_id"></a> [wif\_pool\_id](#input\_wif\_pool\_id) | Short pool id (final path component). Only used when hub\_project\_id is set. | `string` | `"github-pool"` | no |
| <a name="input_wif_pool_name"></a> [wif\_pool\_name](#input\_wif\_pool\_name) | Full pool resource name, taken from gcp-platform bootstrap's<br/>wif\_pool\_name output. Supplying this skips the data-source lookup<br/>entirely and needs NO permission on the hub project. This is a<br/>permanently supported path, not a deprecated one -- prefer it when the<br/>operator cannot be granted hub read, or when bootstrap must plan while<br/>the hub is unavailable. Mutually exclusive with hub\_project\_id. | `string` | `null` | no |
| <a name="input_wif_provider_id"></a> [wif\_provider\_id](#input\_wif\_provider\_id) | Short provider id (final path component). Only used when hub\_project\_id is set. | `string` | `"github-provider"` | no |
| <a name="input_wif_provider_name"></a> [wif\_provider\_name](#input\_wif\_provider\_name) | Full provider resource name. Same trade-off as wif\_pool\_name. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_pool_name"></a> [pool\_name](#output\_pool\_name) | Full pool resource name, however it was obtained. |
| <a name="output_provider_name"></a> [provider\_name](#output\_provider\_name) | Full provider resource name. Set as the GitHub Actions WIF\_PROVIDER variable. |
| <a name="output_resolution_mode"></a> [resolution\_mode](#output\_resolution\_mode) | Whether pool\_name/provider\_name came from a hub data-source lookup ("lookup") or a passed-in string ("static"). Surfaces the hub-permission dependency in plan output. |
<!-- END_TF_DOCS -->
