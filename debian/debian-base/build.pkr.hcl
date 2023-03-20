build {
  sources = ["source.virtualbox-iso.debian-11"]

  provisioner "shell" {
    environment_vars = [
      "PACKER_DIR=${var.packer_dir}",
      "PACKER_VIRT_SYSPREP_DIR=${var.packer_virt_sysprep_dir}"
    ]
    execute_command = "sudo {{ .Vars }} $(command -v bash) '{{ .Path }}'"
    inline = [
      "mkdir --mode=777 $PACKER_DIR",
      "mkdir --mode=777 $PACKER_VIRT_SYSPREP_DIR"
    ]
  }

  provisioner "file" {
    destination = "${var.packer_virt_sysprep_dir}"
    source      = "../../common/scripts/packer-virt-sysprep/"
  }

  provisioner "shell" {
    environment_vars = [
      "ADMIN_CREATE=${var.admin_create}",
      "ADMIN_GECOS=${var.admin_gecos}",
      "ADMIN_GID=${var.admin_gid}",
      "ADMIN_GROUP=${var.admin_group}",
      "ADMIN_GROUPS=${var.admin_groups}",
      "ADMIN_PASSWD=${var.admin_passwd}",
      "ADMIN_SHELL=${var.admin_shell}",
      "ADMIN_SSH_AUTHORISED_KEY=${var.admin_ssh_authorised_key}",
      "ADMIN_UID=${var.admin_uid}",
      "ADMIN_USER=${var.admin_user}",
      "APT_INSTALL_RECOMMENDS=${var.apt_install_recommends}",
      "DEBUG=${var.debug}",
      "GUEST_ADDITIONS_PATH=${var.guest_additions_path}",
      "PACKER_VIRT_SYSPREP_DIR=${var.packer_virt_sysprep_dir}"
    ]
    execute_command = "sudo {{ .Vars }} $(command -v bash) '{{ .Path }}'"
    remote_folder   = "${var.packer_dir}"
    scripts = [
      "../common/scripts/00-grub-config.sh",
      "../common/scripts/01-disable-system-beep.sh",
      "../common/scripts/02-configure-ssh.sh",
      "../common/scripts/03-configure-chrony.sh",
      "../common/scripts/04-configure-timedate-settings.sh",
      "../common/scripts/05-debian-fix-mesg-n-when-not-tty.sh",
      "../common/scripts/06-debian-fix-ifup-lockup.sh",
      "../common/scripts/07-create-admin-user.sh",
      "../common/scripts/20-install-vbox-guest-additions.sh",
      "../common/scripts/30-remove-old-kernels.sh",
      "../common/scripts/31-remove-extraneous-packages.sh",
      "../common/scripts/32-set-apt-install-recommends.sh",
      "../../common/scripts/main/80-create-packer-virt-sysprep-unit-file.sh",
      "../../common/scripts/main/81-create-packer-virt-sysprep-run-control-script.sh",
      "../../common/scripts/main/82-create-remove-packer-user-unit-file.sh"
    ]
    skip_clean = true
  }

  provisioner "shell" {
    environment_vars = ["PACKER_DIR=${var.packer_dir}"]
    execute_command  = "sudo {{ .Vars }} $(command -v bash) '{{ .Path }}'"
    inline           = ["rm -rf $PACKER_DIR"]
  }

  provisioner "file" {
    destination = "${var.zero_script_upload_path}"
    source      = "../../common/scripts/main/zero-free-space.sh"
  }

  provisioner "shell" {
    environment_vars = ["ZERO_SCRIPT_UPLOAD_PATH=${var.zero_script_upload_path}"]
    execute_command  = "sudo {{ .Vars }} $(command -v bash) '{{ .Path }}'"
    script           = "../../common/scripts/main/90-create-zero-free-space-unit-file.sh"
  }

  post-processor "shell-local" {
    environment_vars = [
      "BOX_USERNAME=${var.admin_user}",
      "BOX_USERPASSWD=${var.admin_passwd}",
      "COMMUNICATOR=${var.communicator}",
      "DEBUG=${var.debug}",
      "TEMPLATE=${var.template}",
      "VAGRANTFILE_BASE_DIR=${var.vagrantfile_base_dir}",
      "VAGRANTFILE_NAME=${var.vagrantfile_filename_prefix}.${source.type}",
      "VAGRANT_CLOUD_ORG=${var.vagrant_cloud_org}"
    ]
    execute_command = ["${var.local_shell_binary}", "-c", "chmod +x {{ .Script }} && {{ .Vars }} {{ .Script }}; chmod -x {{ .Script }}"]
    scripts         = ["../../common/scripts/post-processor/00-generate-box-vagrantfiles.sh"]
  }
  post-processors {
    post-processor "vagrant" {
      keep_input_artifact            = true
      output                         = "boxes/${var.template}-${source.type}.box"
      vagrantfile_template           = "${var.vagrantfile_base_dir}/${var.template}/${var.vagrantfile_filename_prefix}.${source.type}"
      vagrantfile_template_generated = true
    }
    post-processor "vagrant-cloud" {
      access_token        = "${var.vagrant_cloud_access_token}"
      box_tag             = "${var.vagrant_cloud_org}/${var.template}"
      version             = "${formatdate("YYYYMM.DD", timestamp())}.${var.vagrant_cloud_revision}"
      version_description = "Packer templates available on [GitHub](https://github.com/DanHam/packer-templates)"
    }
  }
  post-processor "shell-local" {
    environment_vars = [
      "DEBUG=${var.debug}",
      "VAGRANTFILE_BASE_DIR=${var.vagrantfile_base_dir}"
    ]
    execute_command = ["${var.local_shell_binary}", "-c", "chmod +x {{ .Script }} && {{ .Vars }} {{ .Script }}; chmod -x {{ .Script }}"]
    scripts         = ["../../common/scripts/post-processor/99-clean-up-generated-box-vagrantfiles.sh"]
  }
}
