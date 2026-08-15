# project-services

Enables a list of APIs on a project. Extracted from the near-identical
`google_project_service` block that used to be copy-pasted into every
repo's `bootstrap/`.

<!-- BEGIN_TF_DOCS -->
Enables a set of GCP APIs on a project.

Extracted from the near-identical `google_project_service.required` block
that used to be copy-pasted into every repo's bootstrap/.

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
| [google_project_service.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project to enable the APIs in. | `string` | n/a | yes |
| <a name="input_services"></a> [services](#input\_services) | Fully-qualified service names to enable, e.g. run.googleapis.com. | `list(string)` | n/a | yes |
| <a name="input_disable_on_destroy"></a> [disable\_on\_destroy](#input\_disable\_on\_destroy) | Whether to disable these APIs when this config is destroyed. Defaults to<br/>false: disabling an API breaks every other resource in the project that<br/>depends on it, which is almost never what a targeted destroy intends. | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_enabled_services"></a> [enabled\_services](#output\_enabled\_services) | The service names that were enabled, for use in depends\_on. |
<!-- END_TF_DOCS -->
