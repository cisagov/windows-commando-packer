packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.2"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1.1"
    }
  }
  # The required_plugins section is only supported in Packer 1.7.0 and
  # later.  We also want to avoid jumping to Packer v2 until we are
  # ready.
  required_version = "~> 1.7"
}

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

# There are no Windows Server ARM64 base AMIs.
# data "amazon-ami" "windows_server_2022_arm64" {
#   filters = {
#     architecture        = "arm64"
#     name                = "Windows_Server-2022-English-Full-Base-*"
#     root-device-type    = "ebs"
#     virtualization-type = "hvm"
#   }
#   most_recent = true
#   owners      = ["amazon"]
#   region      = var.build_region
# }

data "amazon-ami" "windows_server_2022_x86_64" {
  filters = {
    architecture        = "x86_64"
    name                = "Windows_Server-2022-English-Full-Base-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["amazon"]
  region      = var.build_region
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# There are no Windows Server ARM64 base AMIs.
# source "amazon-ebs" "arm64" {
#   ami_name                    = "windows-server-2022-${local.timestamp}-arm64-ebs"
#   ami_regions                 = var.ami_regions
#   associate_public_ip_address = true
#   communicator                = "winrm"
#   encrypt_boot                = true
#   instance_type               = "t4g.large"
#   kms_key_id                  = var.build_region_kms
#   launch_block_device_mappings {
#     delete_on_termination = true
#     device_name           = "/dev/xvda"
#     encrypted             = true
#     volume_size           = 8
#     volume_type           = "gp3"
#   }
#   region             = var.build_region
#   region_kms_key_ids = var.region_kms_keys
#   skip_create_ami    = var.skip_create_ami
#   source_ami         = data.amazon-ami.windows_server_2022_arm64.id
#   subnet_filter {
#     filters = {
#       "tag:Name" = "AMI Build"
#     }
#   }
#   tags = {
#     Application        = "Windows Server 2022"
#     Architecture       = "arm64"
#     Base_AMI_Name      = data.amazon-ami.windows_server_2022_arm64.name
#     GitHub_Release_URL = var.release_url
#     OS_Version         = "Windows Server 2022"
#     Pre_Release        = var.is_prerelease
#     Release            = var.release_tag
#     Team               = "VM Fusion - Development"
#   }
#   user_data_file = "src/winrm_bootstrap.txt"
#   vpc_filter {
#     filters = {
#       "tag:Name" = "AMI Build"
#     }
#   }
#   winrm_insecure = true
#   winrm_password = var.winrm_password
#   winrm_timeout  = "20m"
#   winrm_use_ssl  = true
#   winrm_username = var.winrm_username
# }

source "amazon-ebs" "x86_64" {
  ami_name                    = "windows-server-2022-${local.timestamp}-x86_64-ebs"
  ami_regions                 = var.ami_regions
  associate_public_ip_address = true
  communicator                = "winrm"
  encrypt_boot                = true
  instance_type               = "t3.large"
  kms_key_id                  = var.build_region_kms
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/xvda"
    encrypted             = true
    volume_size           = 8
    volume_type           = "gp3"
  }
  region             = var.build_region
  region_kms_key_ids = var.region_kms_keys
  skip_create_ami    = var.skip_create_ami
  source_ami         = data.amazon-ami.windows_server_2022_x86_64.id
  subnet_filter {
    filters = {
      "tag:Name" = "AMI Build"
    }
  }
  tags = {
    Application        = "Windows Server 2022"
    Architecture       = "x86_64"
    Base_AMI_Name      = data.amazon-ami.windows_server_2022_x86_64.name
    GitHub_Release_URL = var.release_url
    OS_Version         = "Windows Server 2022"
    Pre_Release        = var.is_prerelease
    Release            = var.release_tag
    Team               = "VM Fusion - Development"
  }
  user_data_file = "src/winrm_bootstrap.txt"
  vpc_filter {
    filters = {
      "tag:Name" = "AMI Build"
    }
  }
  winrm_insecure = true
  winrm_password = var.winrm_password
  winrm_timeout  = "20m"
  winrm_use_ssl  = true
  winrm_username = var.winrm_username
}

build {
  sources = [
    # There are no Windows Server ARM64 base AMIs.
    # "source.amazon-ebs.arm64",
    "source.amazon-ebs.x86_64",
  ]

  provisioner "powershell" {
    # Wait 10 seconds before executing the disable-defender.ps1 powershell script.
    # This gives a small grace period between booting up for the first time and running the first provisioner.
    pause_before = "10s"
    scripts      = ["src/powershell/disable-defender.ps1"]
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    # Wait 90 seconds before executing the check-defender.ps1 powershell script.
    # This gives a generous grace period between restarting Windows and running the second provisioner.
    pause_before = "90s"
    scripts      = ["src/powershell/check-defender.ps1"]
  }

  provisioner "powershell" {
    scripts = ["src/powershell/enable-rdp.ps1"]
  }
}
