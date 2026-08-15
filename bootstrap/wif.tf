/**
 * The one Workload Identity Federation pool + OIDC provider shared by every
 * repo under the gcp-terraform-repos org.
 *
 * Trust is layered deliberately:
 *
 *   - This pool trusts the ORG (attribute_condition checks repository_owner
 *     only). That is what makes it reusable across repos without touching
 *     this hub project again for each new one.
 *   - Each repo's actual access is bounded downstream, in ITS OWN project, by
 *     the workloadIdentityUser binding on ITS OWN CI service account -- see
 *     modules/ci-service-account. That binding names the specific repository,
 *     e.g. attribute.repository/gcp-terraform-repos/gcp-keycloak-infrastructure.
 *
 * A pool being org-scoped does NOT by itself let one repo impersonate
 * another's service account: impersonation requires a matching IAM binding on
 * that specific SA, which each consuming repo's own bootstrap creates for
 * itself. Do not widen this attribute_condition further (e.g. dropping the
 * repository_owner check) -- that would let any GitHub repo on the internet
 * request tokens this pool accepts.
 */

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions"
  description               = "Federated identity for GitHub Actions workflows across gcp-terraform-repos"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub OIDC"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.ref"              = "assertion.ref"
  }

  attribute_condition = <<-EOT
    assertion.repository_owner == "${var.github_owner}"
  EOT

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
