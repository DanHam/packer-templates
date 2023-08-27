variable "admin_create" {
  type        = bool
  description = "Controls whether to create the admin user"
  default     = true
}

variable "admin_gecos" {
  type        = string
  description = "The GECOS data to use when creating the admin user"
  default     = "Debian Administrator"
}

variable "admin_gid" {
  type        = string
  description = "The group ID to use when creating the admin user"
  default     = "1000"
}

variable "admin_group" {
  type        = string
  description = "The group name to use when creating the admin user"
  default     = "vagrant"
}

variable "admin_groups" {
  type        = string
  description = "The list of additional groups the admin user should be made a member of"
  default     = "cdrom,floppy,sudo,audio,dip,video,plugdev,netdev,systemd-journal"
}

variable "admin_passwd" {
  type        = string
  description = "The password for the admin user"
  default     = "vagrant"
}

variable "admin_shell" {
  type        = string
  description = "The default shell for the admin user"
  default     = "/bin/bash"
}

variable "admin_ssh_authorised_key" {
  type        = string
  description = "The SSH key data to add to the admin users ~/.ssh/authorized_keys file"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
}

variable "admin_uid" {
  type        = string
  description = "The user ID to use when creating the admin user"
  default     = "1000"
}

variable "admin_user" {
  type        = string
  description = "The user name for the admin user"
  default     = "vagrant"
}

variable "apt_install_recommends" {
  type        = bool
  description = "Control whether APT should install recommended packages by default in the resultant VM"
  default     = "true"
}

variable "communicator" {
  type        = string
  description = "The default communicator that Packer should use to communicate with the builder"
  default     = "ssh"
}

variable "cpu_count" {
  type        = number
  description = "The number of vCPU's to use in the build VM"
  default     = 1
}

variable "debug" {
  type        = bool
  description = "Control whether provisioner scripts should output debug information"
  default     = false
}

variable "disk_size" {
  type        = number
  description = "The size, in MB to allocate to the VM disk"
  default     = 25600
}

variable "gfx_controller" {
  type        = string
  description = "The VM graphics controller - can be one of none, vboxvga, vboxsvga, or vmsvga"
  default     = "vmsvga"
}

variable "gfx_vram_size" {
  type        = number
  description = "The memory to assign to the VM graphics controller"
  default     = 22
}

variable "guest_additions_path" {
  type        = string
  description = "The upload path for the VirtualBox Guest additions ISO"
  default     = "/tmp/VBoxGuestAdditions.iso"
}

variable "guest_os_type" {
  type        = string
  description = "The VirtualBox guest OS type"
  default     = "Debian_64"
}

variable "headless" {
  type        = bool
  description = "Controls whether VirtualBox should run headless or not"
  default     = false
}

variable "installer_boot_time" {
  type        = string
  description = "The amount of time Packer should wait before attempting to 'type' the boot command"
  default     = "5s"
}

variable "iso_checksum" {
  type        = string
  description = "The checksum for the installer ISO image"
}

variable "iso_url" {
  type        = string
  description = "The URL to the installer ISO image"
}

variable "local_shell_binary" {
  type        = string
  description = "The path to the bash shell binary on the system running the build"
  default     = "/usr/bin/bash"
}

variable "memory_size" {
  type        = number
  description = "The amount of memory to allocate to the build VM"
  default     = 2048
}

variable "packer_dir" {
  type        = string
  description = "The path to create and use in the build VM for uploading all provisioner scripts"
  default     = "/packer"
}

variable "packer_virt_sysprep_dir" {
  type        = string
  description = "The path to create and use in the build VM for uploading all packer-virt-sysprep scripts and files"
  default     = "/packer-virt-sysprep"
}

variable "part_scheme" {
  type        = string
  description = "The partitioning scheme to use. Can be either 'std' for standard partitioning or 'lvm' for partitioning with LVM"
  default     = "std"
}

variable "shutdown_command" {
  type        = string
  description = "The command to use for shutting down the VM"
  default     = "sudo /sbin/poweroff"
}

variable "ssh_private_key" {
  type        = string
  description = "The path to the SSH private key Packer should use when setting up communication with the build VM"
  default     = "../../common/keys/vagrant"
}

variable "ssh_username" {
  type        = string
  description = "The SSH user Packer should use when setting up communication with the build VM"
  default     = "packer"
}

variable "template" {
  type        = string
  description = "The base name for the Packer build"
}

variable "vagrant_cloud_access_token" {
  type        = string
  description = "The Vagrant Cloud access token"
  default     = env("VAGRANT_CLOUD_ACCESS_TOKEN")
  sensitive   = true

  validation {
    condition     = length(var.vagrant_cloud_access_token) > 0
    error_message = "Please ensure the VAGRANT_CLOUD_ACCESS_TOKEN env var is set."
  }
}

variable "vagrant_cloud_org" {
  type        = string
  description = "The Vagrant Cloud organisation to use when uploading the Vagrant Box"
  default     = "foosite"
}

variable "vagrant_cloud_revision" {
  type        = string
  description = "The user configurable portion of the Vagrant box release string"
  default     = "0"
}

variable "vagrantfile_base_dir" {
  type        = string
  description = "The directory containing Vagrantfile snippets used to configure settings in the resultant Vagrant box"
  default     = "vagrantfiles"
}

variable "vagrantfile_filename_prefix" {
  type        = string
  description = "The prefix used for Vagrantfile snippets"
  default     = "Vagrantfile"
}

variable "zero_script_upload_path" {
  type        = string
  description = "The path Packer should upload the 'zero free space' script to within the build VM"
  default     = "/tmp/zero-free-space.sh"
}
