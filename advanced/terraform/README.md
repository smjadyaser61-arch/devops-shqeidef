# Advanced Lab A4 — Terraform Modules & Terragrunt

Rewrites the Milestone 3 bucket as a reusable module, calls it from two
environments (`dev` and `staging`), and uses Terragrunt so the backend and
provider are written once instead of twice.

## Folder structure

### Before (Session 2 / M3)

One flat root, one environment, state on the laptop:

```
terraform/
├── main.tf               # provider + 3 resources + 2 outputs, all in one file
├── NOTES.md
├── .terraform.lock.hcl
└── terraform.tfstate     # local file, unencrypted, unlocked
```

The `environment` was a variable with a `dev` default, so a second environment
meant either re-running with `-var` and clobbering the same state file, or
copy-pasting the whole root.

### After (Session 3 / A4)

```
advanced/terraform/
├── README.md
├── root.hcl                      # backend + provider, defined once
├── modules/
│   └── s3-bucket/                # no provider, no backend, no env names
│       ├── main.tf               # bucket + versioning + encryption
│       ├── variables.tf          # bucket_name, environment, cost_center, owner
│       └── outputs.tf            # bucket_name, bucket_arn
└── environments/
    ├── dev/
    │   ├── main.tf               # one module call + two outputs
    │   └── terragrunt.hcl        # include "root"
    └── staging/
        ├── main.tf               # one module call + two outputs
        └── terragrunt.hcl        # include "root"
```

State moved from a local file to `s3://shipfast-tfstate-<account-id>/`, with a
separate key per environment (`dev/terraform.tfstate`,
`staging/terraform.tfstate`) derived from `path_relative_to_include()`.
Locking uses the native S3 lockfile (`use_lockfile = true`) — no DynamoDB table.

## Answers

### 1. Why did you destroy the M3 infrastructure first instead of keeping it?

Moving the resources into a module changes every resource address: what was
`aws_s3_bucket.artifacts` becomes `module.artifacts.aws_s3_bucket.artifacts`.
The old state still maps the real bucket to the old address, so Terraform would
plan to destroy three resources and create three new ones — and the create would
fail anyway, because a bucket with that name already exists. Destroying first
is the cheapest way to get a clean slate; keeping it would have meant writing
`moved` blocks or running `terraform state mv` for each resource.

### 2. Tags: one map variable or separate variables, and why?

Separate variables. The module takes `environment`, `cost_center` and `owner` as
individual `string` inputs and assembles the tag map itself, with `ManagedBy`
fixed to `terraform` since no caller should ever override it. A single free-form
`tags` map would let a caller silently omit `CostCenter` or `Owner` — and those
two are exactly the tags Week 8 cost reporting depends on. Separate required
variables make Terraform fail at plan time instead of producing an untagged
bucket that nobody notices until the cost report is wrong.

### 3. How did you create the state bucket, and why can Terraform not create it for itself?

It is a chicken-and-egg problem: the backend has to exist *before*
`terraform init` can write state into it, so a run cannot create the bucket that
same run is storing its state in. The bucket is therefore created outside this
Terraform code and is deliberately not managed by it — which also means a
`terraform destroy` in either environment can never take the state bucket with it.

<!-- PENDING: confirm after the first live run (needs AWS credentials).
     Record here which route you used — the AWS CLI commands, or
     `terragrunt run --all apply --backend-bootstrap` — and paste the CLI output
     proving versioning, encryption and Block Public Access are on. -->

### 4. Why keep one state file per environment instead of using Terraform workspaces?

Blast radius. Each environment folder is its own Terraform root with its own
state object and its own lock, so a plan in `staging` physically cannot read or
write `dev`'s state, and the two can be locked and applied independently.
Workspaces would put both environments behind one root and one backend
configuration, where the only thing standing between a `staging` change and
`dev` is remembering to run `terraform workspace select` — and the difference
between environments stops being visible in the code at all. Separate state
files also let you scope IAM per key prefix, which workspaces cannot do.

## Running it

From `advanced/terraform/environments/`:

```bash
terragrunt run --all plan
terragrunt run --all apply
```

The generated `backend.tf` and `provider.tf` are gitignored — Terragrunt
rewrites them on every run. The `.terraform.lock.hcl` in each environment folder
is committed on purpose, so provider versions are pinned across machines.

## Task 6 — staging-only change experiment

<!-- PENDING: run after AWS credentials are configured.
     Change `owner` in environments/staging/main.tf only, predict the result,
     then run `terragrunt run --all plan` from environments/ and record:
       - what the dev plan reported   (expected: No changes)
       - what the staging plan reported (expected: 1 to change, tag update)
       - why that separation matters for blast radius
     Then apply and confirm dev was untouched. -->
