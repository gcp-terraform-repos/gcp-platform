# Changelog

All notable changes to this repo's consumable modules are recorded here.
Consumers pin `?ref=` to a tag; this file is how you decide whether bumping
that ref is safe.

## v1.2.0

- Added `modules/artifact-registry`, promoted from gcp-keycloak-infrastructure. The `keep_versions` cap is now a wider 1-10 range instead of that repo's hardcoded 2 -- size it per consumer against your own image size and free-tier/budget allowance.
- Repo made public (was private): it holds no secrets, only reusable module code and IAM/WIF plumbing, and being private was blocking CI in every consuming repo from validating `git::`-sourced module downloads.

## v1.1.0

Additive only -- `?ref=v1.0.0` keeps resolving unchanged.

- Added `modules/project-services` -- enables a list of APIs on a project.
- Added `modules/tf-state-bucket` -- a private, versioned state bucket, with the free-tier region validation.
- Added `modules/wif-lookup` -- resolves the WIF pool/provider by data-source lookup (`hub_project_id`) or by string passthrough (`wif_pool_name`/`wif_provider_name`, unchanged, permanently supported, needs no hub permission).
- Added `modules/repo-bootstrap` -- composes the above plus `ci-service-account` into the one module a new repo's `bootstrap/` should call.
- `modules/ci-service-account`: `roles` now defaults to `[]` (was required). Added outputs `service_account_name`, `service_account_id`, `unique_id`, `member`, `wif_principal_set`.
- Added `examples/new-repo-bootstrap/`.

## v1.0.0

Initial WIF pool + `ci-service-account` module.
