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
#   user_data_file = "winrm_bootstrap.txt"
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
