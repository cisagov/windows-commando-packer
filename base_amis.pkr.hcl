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
