# tf-pipeline-circleci

...

## Bootstrap

The bootstrap relies on <https://github.com/trussworks/terraform-aws-bootstrap>.

```bash
STAGE=dev
cd accounts/$STAGE/bootstrap
terraform init
terraform plan -var-file ../terraform.tfvars
terraform apply -var-file ../terraform.tfvars
```

### Trust Relationships

For allowing cross account deployment from dev to qa and dev to prod we need to adjust the OrganizationAccountAccessRoles in the accounts. First go to to dev account and allow the assumption of the account itself. e.g.:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<ROOT_ACCOUNT>:root"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<DEV_ACCOUNT>:root"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

Now go to the qa account OrganizationAccountAccessRole and allow the assumption by itself and the dev account:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<ROOT_ACCOUNT>:root"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<QA_ACCOUNT>:root"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<DEV_ACCOUNT>:root"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

Do the same for prod!

## Deploy

For deploying changes to the dev, qa or prod stage you can use CircleCI which has a CI/CD staging pipeline setup.

### Manually

This instructions are for deploying manually. For all stages except perhaps for dev you shouldn't really deploy manually ad rely on the CI/CD staging pipeline in CircleCI.

```bash
STAGE=dev
ACCOUNT_ID=<QA_ACCOUNT>

export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
$(aws sts assume-role \
--role-arn arn:aws:iam::$ACCOUNT_ID:role/OrganizationAccountAccessRole \
--role-session-name OrganizationAccountAccessRole \
--query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
--output text))

terraform init -backend-config accounts/$STAGE/backend.conf -reconfigure
terraform plan -out tfapply -var-file accounts/$STAGE/terraform.tfvars
terraform apply -auto-approve tfapply

terraform apply -destroy -var-file accounts/$STAGE/terraform.tfvars
```
