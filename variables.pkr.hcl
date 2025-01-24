# ------------------------------------------------------------------------------
# Required parameters
#
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Optional parameters
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------

variable "ami_regions" {
  default     = []
  description = "The list of AWS regions to copy the AMI to once it has been created. Example: [\"us-east-1\"]"
  type        = list(string)
}

variable "build_region" {
  default     = "us-east-1"
  description = "The region in which to retrieve the base AMI from and build the new AMI."
  type        = string
}

variable "build_region_kms" {
  default     = "alias/cool-amis"
  description = "The ID or ARN of the KMS key to use for AMI encryption."
  type        = string
}

variable "github_ref_name" {
  default     = ""
  description = "The GitHub short ref name to use for the tags applied to the created AMI."
  type        = string
}

variable "github_sha" {
  default     = ""
  description = "The GitHub commit SHA to use for the tags applied to the created AMI."
  type        = string
}
variable "is_prerelease" {
  default     = false
  description = "The pre-release status to use for the tags applied to the created AMI."
  type        = bool
}

variable "region_kms_keys" {
  default     = {}
  description = "A map of regions to copy the created AMI to and the KMS keys to use for encryption in that region. The keys for this map must match the values provided to the aws_regions variable. Example: {\"us-east-1\": \"alias/example-kms\"}"
  type        = map(string)
}

variable "release_tag" {
  default     = ""
  description = "The GitHub release tag to use for the tags applied to the created AMI."
  type        = string
}

variable "release_url" {
  default     = ""
  description = "The GitHub release URL to use for the tags applied to the created AMI."
  type        = string
}

variable "skip_create_ami" {
  default     = false
  description = "Indicate if Packer should not create the AMI."
  type        = bool
}

# The 'winrm_password' variable is configured as an optional variable because
# the cisagov/pre-commit-packer hook does not support passing variables to
# `packer validate`. Once this limitation is removed this should be changed to
# a required variable. Please see the following for more information:
# https://github.com/cisagov/windows-server-packer/issues/21
variable "winrm_password" {
  default     = ""
  description = "The password used to connect to the instance via WinRM."
  sensitive   = true
  type        = string
}

variable "winrm_username" {
  default     = "Administrator"
  description = "The username used to connect to the instance via WinRM."
  type        = string
}
