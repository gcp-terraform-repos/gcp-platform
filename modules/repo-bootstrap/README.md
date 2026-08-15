# repo-bootstrap

The single module a new repo's `bootstrap/` should call to get everything
it needs to exist before its own environments can be applied: required
APIs, its own OpenTofu state bucket, and a CI service account scoped into
this repo's shared WIF pool. Composes `project-services` + `tf-state-bucket`
+ `wif-lookup` + `ci-service-account` so a new repo does not re-derive
~80 lines of boilerplate by copy-paste.

See [`../../examples/new-repo-bootstrap/`](../../examples/new-repo-bootstrap/)
for a complete, runnable call.

<!-- BEGIN_TF_DOCS -->
The single module a new repo's bootstrap/ calls to get everything it needs
to exist before its own environments can be applied: required APIs, its own
OpenTofu state bucket, and a CI service account scoped into gcp-platform's
shared WIF pool.

Composes project-services + tf-state-bucket + wif-lookup + ci-service-account
so a new repo does not re-derive ~80 lines of boilerplate by copy-paste.

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

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_ci_identity"></a> [ci\_identity](#module\_ci\_identity) | ../ci-service-account | n/a |
| <a name="module_project_services"></a> [project\_services](#module\_project\_services) | ../project-services | n/a |
| <a name="module_state_bucket"></a> [state\_bucket](#module\_state\_bucket) | ../tf-state-bucket | n/a |
| <a name="module_wif"></a> [wif](#module\_wif) | ../wif-lookup | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [google_storage_bucket_iam_member.ci_state](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | The consuming repo's name, without the owner prefix. Scopes CI impersonation to exactly this repo. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The consuming repo's own GCP project -- not the hub. | `string` | n/a | yes |
| <a name="input_activate_apis"></a> [activate\_apis](#input\_activate\_apis) | Additional APIs to enable, on top of the always-on iam/iamcredentials/sts/storage baseline. | `list(string)` | `[]` | no |
| <a name="input_ci_account_id"></a> [ci\_account\_id](#input\_ci\_account\_id) | CI service account id. Defaults to "<github\_repo>-ci", truncated to the 30-char limit. | `string` | `null` | no |
| <a name="input_ci_description"></a> [ci\_description](#input\_ci\_description) | What the CI service account does; shown in the GCP console. | `string` | `"Runs CI/CD from GitHub Actions via Workload Identity Federation"` | no |
| <a name="input_ci_display_name"></a> [ci\_display\_name](#input\_ci\_display\_name) | Human-readable name for the CI service account. | `string` | `"CI/CD"` | no |
| <a name="input_ci_roles"></a> [ci\_roles](#input\_ci\_roles) | Project-level IAM roles for the CI service account. | `list(string)` | `[]` | no |
| <a name="input_create_state_bucket"></a> [create\_state\_bucket](#input\_create\_state\_bucket) | Create a Tofu state bucket in this project. Set false if the repo shares an existing bucket. | `bool` | `true` | no |
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | GitHub org the consuming repo lives under. | `string` | `"gcp-terraform-repos"` | no |
| <a name="input_grant_state_bucket_access"></a> [grant\_state\_bucket\_access](#input\_grant\_state\_bucket\_access) | Grant the CI service account objectAdmin on the state bucket only. Bucket-scoped by design -- never project-wide storage admin. Ignored if create\_state\_bucket is false. | `bool` | `true` | no |
| <a name="input_hub_project_id"></a> [hub\_project\_id](#input\_hub\_project\_id) | gcp-platform hub project ID, for a data-source lookup of the WIF pool/provider. Requires roles/iam.workloadIdentityPoolViewer on the hub for whoever applies this. Mutually exclusive with wif\_pool\_name/wif\_provider\_name. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region for the state bucket. Must be a Cloud Storage free-tier region. | `string` | `"us-east1"` | no |
| <a name="input_wif_pool_id"></a> [wif\_pool\_id](#input\_wif\_pool\_id) | Short pool id. Only used when hub\_project\_id is set. | `string` | `"github-pool"` | no |
| <a name="input_wif_pool_name"></a> [wif\_pool\_name](#input\_wif\_pool\_name) | Full pool resource name from gcp-platform bootstrap's wif\_pool\_name output. Needs no permission on the hub project. Mutually exclusive with hub\_project\_id. | `string` | `null` | no |
| <a name="input_wif_provider_id"></a> [wif\_provider\_id](#input\_wif\_provider\_id) | Short provider id. Only used when hub\_project\_id is set. | `string` | `"github-provider"` | no |
| <a name="input_wif_provider_name"></a> [wif\_provider\_name](#input\_wif\_provider\_name) | Full provider resource name from gcp-platform bootstrap's wif\_provider\_name output. Same trade-off as wif\_pool\_name. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_ci_service_account_email"></a> [ci\_service\_account\_email](#output\_ci\_service\_account\_email) | Email of the CI service account. Set as the GitHub Actions variable CI\_SERVICE\_ACCOUNT. |
| <a name="output_ci_service_account_member"></a> [ci\_service\_account\_member](#output\_ci\_service\_account\_member) | Ready-made IAM member string, "serviceAccount:<email>". |
| <a name="output_github_variables_command"></a> [github\_variables\_command](#output\_github\_variables\_command) | Copy-paste to configure the repo. These are variables, not secrets -- none of them are sensitive. |
| <a name="output_state_bucket"></a> [state\_bucket](#output\_state\_bucket) | Name of the state bucket, or null if create\_state\_bucket = false. |
| <a name="output_wif_pool_name"></a> [wif\_pool\_name](#output\_wif\_pool\_name) | Full WIF pool resource name, however it was resolved. |
| <a name="output_wif_provider_name"></a> [wif\_provider\_name](#output\_wif\_provider\_name) | Full WIF provider resource name, however it was resolved. Set as the GitHub Actions WIF\_PROVIDER variable. |
| <a name="output_wif_resolution_mode"></a> [wif\_resolution\_mode](#output\_wif\_resolution\_mode) | "lookup" if hub\_project\_id was used, "static" if wif\_pool\_name/wif\_provider\_name were passed directly. |
<!-- END_TF_DOCS -->
