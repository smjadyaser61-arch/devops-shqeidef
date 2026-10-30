# ShipFast M3 — Terraform Notes

## Plan Prediction

I expect Terraform to create 3 resources:

1. AWS S3 bucket
2. S3 bucket versioning configuration
3. S3 bucket encryption configuration

The bucket ARN and some resource IDs may be
shown as "known after apply" because the resources
have not yet been created.

## Task 5 — Terraform State

Terraform state maps the resource addresses defined
in Terraform configuration to the real resources
created in AWS.

For example, aws_s3_bucket.artifacts is the
Terraform resource address, while
shipfast-artifacts-dev-563807597492 is the
actual AWS S3 bucket ID.

Terraform uses this mapping to identify and manage
existing infrastructure instead of recreating it.

## Task 6 — Terraform Experiments

### Experiment 1 — Apply Without Changes

Prediction:
Terraform will detect no changes because the
infrastructure already matches the configuration.

Result:
Terraform reported no changes.

Explanation:
Terraform compares the configuration, state,
and actual AWS infrastructure. Since they match,
Terraform does not need to modify any resources.

### Experiment 2 — Manual Tag Change

Prediction:
Terraform will detect that an additional tag was
manually added to the S3 bucket.

I expect Terraform to update the bucket in place
to restore the configuration defined in main.tf.

Result:
Terraform detected the manually added tag and
updated the S3 bucket in place to remove it.

Explanation:
Terraform refreshes its knowledge of the actual
AWS infrastructure and compares it with the
declared configuration.

Since ManualChange was not defined in main.tf,
Terraform planned to remove it.

### Experiment 3 — Change Environment

Prediction:
Changing the environment from dev to staging
will change the S3 bucket name.

Since an S3 bucket cannot be renamed, Terraform
will plan to replace the existing bucket.

I expect to see the -/+ symbol, indicating
that Terraform must destroy and recreate the resource.

Result:
Terraform planned to replace the S3 bucket
because changing the environment also changes
its name.

The -/+ symbol indicated destroy and recreate.

Explanation:
S3 bucket names cannot be changed in place.
Terraform must replace the bucket to use the
new name.

Replacing a production database is generally
more dangerous than replacing an empty S3 bucket
because it may involve data loss and downtime.
