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
    scripts      = ["ansible/powershell/disable-defender.ps1"]
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
    scripts      = ["ansible/powershell/check-defender.ps1"]
  }

  provisioner "powershell" {
    scripts = ["ansible/powershell/enable-rdp.ps1"]
  }
}
