# tf-state-bucket

A private, versioned GCS bucket for one repo's own OpenTofu state. The
free-tier region validation lives here -- once, at the place it's actually
about -- instead of being duplicated into every repo's `variables.tf`.

<!-- BEGIN_TF_DOCS -->
A private, versioned GCS bucket for one repo's own OpenTofu state.

Extracted from the near-identical `google_storage_bucket.tf_state` block
that used to be copy-pasted into every repo's bootstrap/. The free-tier
region validation lives here -- once, at the place it's actually about --
instead of being duplicated into every repo's variables.tf.

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
| [google_storage_bucket.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project that owns the state bucket. | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Allow deleting a non-empty state bucket. Keep false -- this bucket holds OpenTofu state. | `bool` | `false` | no |
| <a name="input_keep_versions"></a> [keep\_versions](#input\_keep\_versions) | Non-current object versions retained before deletion. | `number` | `20` | no |
| <a name="input_name"></a> [name](#input\_name) | Bucket name. Defaults to "<project\_id>-tf-state". | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Bucket location. Restricted to Cloud Storage free-tier regions. | `string` | `"us-east1"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_name"></a> [name](#output\_name) | Bucket name. Use as the `bucket` in each env's -backend-config. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | Bucket self link. |
| <a name="output_url"></a> [url](#output\_url) | gs:// URL of the bucket. |
<!-- END_TF_DOCS -->
