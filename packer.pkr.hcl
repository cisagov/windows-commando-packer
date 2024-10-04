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

data "amazon-ami" "debian_bookworm_arm64" {
  filters = {
    architecture        = "arm64"
    name                = "debian-12-arm64-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["136693071363"]
  region      = var.build_region
}

data "amazon-ami" "debian_bookworm_x86_64" {
  filters = {
    architecture        = "x86_64"
    name                = "debian-12-amd64-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["136693071363"]
  region      = var.build_region
}
