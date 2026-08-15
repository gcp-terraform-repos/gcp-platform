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
