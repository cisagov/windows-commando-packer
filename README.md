# windows-server-packer 🪟📦 #

[![GitHub Build Status](https://github.com/cisagov/windows-server-packer/workflows/build/badge.svg)](https://github.com/cisagov/windows-server-packer/actions)

This project can be used to create a custom Amazon Machine Image based on
Windows Server 2022.

## Pre-requisites ##

This project requires a build user to exist in AWS. The accompanying Terraform
code will create the user with the appropriate name and permissions. This only
needs to be run once per project, per AWS account. This user will also be used
by GitHub Actions.

Before the build user can be created, the following profile must exist in
your AWS credentials file:

- `cool-terraform-backend`

The easiest way to set up that profile is to use our
[`aws-profile-sync`](https://github.com/cisagov/aws-profile-sync) utility.
Follow the usage instructions in that repository before continuing with the
next steps. Note that you will need to know where your team stores their
remote profile data in order to use
[`aws-profile-sync`](https://github.com/cisagov/aws-profile-sync).

### Creating a build user ###

You will need to create a build user for each environment that you use.  The
following steps show how to create a build user for an environment named "dev".
You will need to repeat this process for any additional environments.

1. Change into the `terraform-build-user` directory:

   ```console
   cd terraform-build-user
   ```

1. Create a backend configuration file named `dev.tfconfig` containing the
name of the bucket where "dev" environment Terraform state is stored - this file
is required to initialize the Terraform backend in each environment:

    ```hcl
    bucket = "my-dev-terraform-state-bucket"
    ```

1. Initialize the Terraform backend for the "dev" environment using your backend
   configuration file:

    ```console
    terraform init -backend-config=dev.tfconfig
    ```

    > [!NOTE]
    > When performing this step for additional environments (i.e. not your first
    > environment), use the `-reconfigure` flag:
    >
    > ```console
    > terraform init -backend-config=other-env.tfconfig -reconfigure
    > ```

1. Create a Terraform variables file named `dev.tfvars` containing all
required variables (currently only `terraform_state_bucket`):

    ```hcl
    terraform_state_bucket = "my-dev-terraform-state-bucket"
    ```

1. Create a Terraform workspace for the "dev" environment:

    ```console
   terraform workspace new dev
   ```

1. Initialize and upgrade the Terraform workspace, then apply the configuration
   to create the build user in the "dev" environment:

    ```console
    terraform init -upgrade=true
    terraform apply -var-file=dev.tfvars
    ```

Once the build user is created you will need to update the
[repository's secrets](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets)
with the new encrypted environment variables. This should be done using the
[`terraform-to-secrets`](https://github.com/cisagov/development-guide/tree/develop/project_setup#terraform-iam-credentials-to-github-secrets-)
tool available in the
[development guide](https://github.com/cisagov/development-guide). Instructions
for how to use this tool can be found in the
["Terraform IAM Credentials to GitHub Secrets" section](https://github.com/cisagov/development-guide/tree/develop/project_setup#terraform-iam-credentials-to-github-secrets-).
of the Project Setup README.

If you have appropriate permissions for the repository you can view existing
secrets on the
[appropriate page](https://github.com/cisagov/windows-server-packer/settings/secrets)
in the repository's settings.

IMPORTANT: The account where your images will be built must have a VPC and
a public subnet both tagged with the name "AMI Build", otherwise `packer`
will not be able to build images.

## Building the image ##

### Using GitHub Actions ###

1. Create a [new release](https://help.github.com/en/articles/creating-releases)
   in GitHub.
1. There is no step 2!

GitHub Actions can build this project in three different modes depending on
how the build was triggered from GitHub.

1. **Development release**: After a normal commit and also on a pull request,
   GitHub Actions will run tests and validation on the Packer template, and then
   build the project.  An image will be built and deployed using the
   [`build`](.github/workflows/build.yml) workflow.  This should be configured
   to deploy the image to a single region using a development account.
1. **Pre-release**: Publish a GitHub release with the "This is a pre-release"
   checkbox checked.  An image will be built and deployed using the
   [`prerelease`](.github/workflows/prerelease.yml) workflow.  This should be
   configured to deploy the image to a single region using a non-production
   account (e.g. "staging").
1. **Production release**: Publish a GitHub release with the "This is a
   pre-release" checkbox unchecked.  An image will be built and deployed using
   the [`release`](.github/workflows/release.yml) workflow.  This should be
   configured to deploy the image to multiple regions using a production
   account.

### Using your local environment ###

Packer will use your
[standard AWS environment](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
to build the image, however you will need to set up one profile for the
previously-created build user and another profile to assume the associated
`EC2AMICreate` role. You will need the `aws_access_key_id` and
`aws_secret_access_key` that you set as GitHub secrets earlier.

Add the following blocks to your AWS credentials file (be sure to replace the
dummy account ID in the `role_arn` with your own):

```console
[build-windows-server-packer]
aws_access_key_id = AKIAXXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

[cool-images-ec2amicreate-windows-server-packer]
role_arn = arn:aws:iam::111111111111:role/EC2AMICreate-build-windows-server-packer
source_profile = build-windows-server-packer
role_session_name = example
```

This Packer template defines a number of variables whose defaults can be changed
through a `.pkrvars.hcl` file:

```hcl
build_region = "us-east-2"
build_region_kms = "alias/example-kms"
is_prerelease = "true"
```

Here is an example of how to kick off a pre-release build:

```console
pip install --requirement requirements-dev.txt
AWS_PROFILE=cool-images-ec2amicreate-windows-server-packer \
packer build --timestamp-ui -var release_tag=$(./bump-version show) \
-var is_prerelease=true -var winrm_password="your-winrm-password" .
```

If you are satisfied with your pre-release image, you can easily create a release
that deploys to all regions by adding additional regions to the Packer template.
This can be done by using a `.pkrvars.hcl` for example with `release.pkrvars.hcl`:

```hcl
ami_regions = ["us-east-2", "us-west-1", "us-west-2"]
region_kms_keys = {
  "us-east-2": "alias/cool-amis",
  "us-west-1": "alias/cool-amis",
  "us-west-2": "alias/cool-amis",
}
winrm_password = "your-winrm-password"
```

```console
AWS_PROFILE=cool-images-ec2amicreate-windows-server-packer packer build --timestamp-ui -var-file release.pkrvars.hcl .
```

### Giving other AWS accounts permission to launch the image ###

After the AMI has been successfully created, you may want to allow other
accounts in your AWS organization permission to launch it.  The following steps
show how to do this for an environment named "dev". You will need to repeat this
process for any additional environments.

> [!NOTE]
> Refer to the `ami_share_account_name_regex` variable if you want to customize
> which accounts in your AWS organization to share your AMI with.

1. Change into the `terraform-post-packer` directory:

   ```console
   cd terraform-post-packer
   ```

1. Create a backend configuration file named `dev.tfconfig` containing the
name of the bucket where "dev" environment Terraform state is stored - this file
is required to initialize the Terraform backend in each environment:

    ```hcl
    bucket = "my-dev-terraform-state-bucket"
    ```

1. Initialize the Terraform backend for the "dev" environment using your backend
   configuration file:

    ```console
    terraform init -backend-config=dev.tfconfig
    ```

    > [!NOTE]
    > When performing this step for additional environments (i.e. not your first
    > environment), use the `-reconfigure` flag:
    >
    > ```console
    > terraform init -backend-config=other-env.tfconfig -reconfigure
    > ```

1. If not already created, create a Terraform workspace for the "dev" environment:

    ```console
   terraform workspace new dev
   ```

   Otherwise, switch to the existing "dev" workspace:

    ```console
   terraform workspace select dev
   ```

1. Initialize and upgrade the Terraform workspace, then apply the configuration
   to share the AMI with accounts in the "dev" environment:

    ```console
    terraform init -upgrade=true
    terraform apply
    ```

<!-- BEGIN_TF_DOCS -->
## Requirements ##

No requirements.

## Providers ##

| Name | Version |
|------|---------|
| amazon-ami | n/a |

## Modules ##

No modules.

## Resources ##

| Name | Type |
|------|------|
| [amazon-ami_amazon-ami.windows_server_2022_x86_64](https://registry.terraform.io/providers/hashicorp/amazon-ami/latest/docs/data-sources/amazon-ami) | data source |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_regions | The list of AWS regions to copy the AMI to once it has been created. Example: ["us-east-1"] | `list(string)` | `[]` | no |
| build\_region | The region in which to retrieve the base AMI from and build the new AMI. | `string` | `"us-east-1"` | no |
| build\_region\_kms | The ID or ARN of the KMS key to use for AMI encryption. | `string` | `"alias/cool-amis"` | no |
| github\_ref\_name | The GitHub short ref name to use for the tags applied to the created AMI. | `string` | `""` | no |
| github\_sha | The GitHub commit SHA to use for the tags applied to the created AMI. | `string` | `""` | no |
| is\_prerelease | The pre-release status to use for the tags applied to the created AMI. | `bool` | `false` | no |
| region\_kms\_keys | A map of regions to copy the created AMI to and the KMS keys to use for encryption in that region. The keys for this map must match the values provided to the aws\_regions variable. Example: {"us-east-1": "alias/example-kms"} | `map(string)` | `{}` | no |
| release\_tag | The GitHub release tag to use for the tags applied to the created AMI. | `string` | `""` | no |
| release\_url | The GitHub release URL to use for the tags applied to the created AMI. | `string` | `""` | no |
| skip\_create\_ami | Indicate if Packer should not create the AMI. | `bool` | `false` | no |
| winrm\_password | The password used to connect to the instance via WinRM. | `string` | `""` | no |
| winrm\_username | The username used to connect to the instance via WinRM. | `string` | `"Administrator"` | no |

## Outputs ##

No outputs.
<!-- END_TF_DOCS -->

<<<<<<< HEAD
=======
## New repositories from a skeleton ##

Please see our [Project Setup guide](https://github.com/cisagov/development-guide/tree/develop/project_setup)
for step-by-step instructions on how to start a new repository from
a skeleton. This will save you time and effort when configuring a
new repository!

>>>>>>> b702664447def7d112564cadeda1ebe32e064c2d
## Contributing ##

We welcome contributions!  Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
