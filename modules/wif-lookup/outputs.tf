output "pool_name" {
  description = "Full pool resource name, however it was obtained."
  value       = local.pool_name

  precondition {
    condition     = local.pool_name != null
    error_message = "Set either hub_project_id (data-source lookup) or wif_pool_name (string passthrough)."
  }
  precondition {
    condition     = !(var.hub_project_id != null && var.wif_pool_name != null)
    error_message = "hub_project_id and wif_pool_name are mutually exclusive; pick one resolution strategy."
  }
}

output "provider_name" {
  description = "Full provider resource name. Set as the GitHub Actions WIF_PROVIDER variable."
  value       = local.provider_name

  precondition {
    condition     = local.provider_name != null
    error_message = "Set either hub_project_id (data-source lookup) or wif_provider_name (string passthrough)."
  }
  precondition {
    condition     = !(var.hub_project_id != null && var.wif_provider_name != null)
    error_message = "hub_project_id and wif_provider_name are mutually exclusive; pick one resolution strategy."
  }
}

output "resolution_mode" {
  description = "Whether pool_name/provider_name came from a hub data-source lookup (\"lookup\") or a passed-in string (\"static\"). Surfaces the hub-permission dependency in plan output."
  value       = local.use_lookup ? "lookup" : "static"
}
