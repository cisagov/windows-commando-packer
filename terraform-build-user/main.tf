module "iam_user" {
  source = "github.com/cisagov/ami-build-iam-user-tf-module?ref=improvement%2Fsingle-build-env"

  providers = {
    aws            = aws
    aws.images-ami = aws.images-ami
    aws.images-ssm = aws.images-ssm
  }

  ssm_parameters = ["/cyhy/dev/users", "/ssh/public_keys/*"]
  user_name      = "build-skeleton-packer"
}
