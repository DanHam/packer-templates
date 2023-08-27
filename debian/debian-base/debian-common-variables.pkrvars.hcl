# Controls whether to create the admin user
admin_create = true
# The GECOS data to use when creating the admin user
admin_gecos = "Debian Administrator"
# The group ID to use when creating the admin user
admin_gid = "1000"
# The group name to use when creating the admin user
admin_group = "vagrant"
# The list of additional groups the admin user should be made a member of
admin_groups = "cdrom,floppy,sudo,audio,dip,video,plugdev,netdev,systemd-journal"
# The password for the admin user
admin_passwd = "vagrant"
# The default shell for the admin user
admin_shell  = "/bin/bash"
# The SSH key data to add to the admin users ~/.ssh/authorized_keys file
admin_ssh_authorised_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
# The user ID to use when creating the admin user
admin_uid = "1000"
# The user name for the admin user
admin_user = "vagrant"
# Control whether APT should install recommended packages by default in the resultant VM
apt_install_recommends = true
# The default communicator that Packer should use to communicate with the builder
communicator = "ssh"
# The number of vCPU's to use in the build VM
cpu_count = "1"
# Control whether provisioner scripts should output debug information
debug = false
# The disk size to use for the resultant VM
disk_size = "25600"
# The upload path for the VirtualBox Guest additions ISO
guest_additions_path = "/tmp/VBoxGuestAdditions.iso"
# The VirtualBox guest OS type
guest_os_type = "Debian_64"
# Controls whether VirtualBox should run headless or not
headless = false
# The amount of time Packer should wait before attempting to 'type' the boot command
installer_boot_time = "5s"
# The path to the bash shell binary on the system running the build
local_shell_binary = "/usr/bin/bash"
# The amount of memory to use for the build VM
memory_size = "2048"
# The path to create and use in the build VM for uploading all provisioner scripts
packer_dir = "/packer"
# The path to create and use in the build VM for uploading all packer-virt-sysprep scripts and files
packer_virt_sysprep_dir = "/packer-virt-sysprep"
# The partitioning scheme to use. Can be either 'std' for standard partitioning or 'lvm' for partitioning with LVM
part_scheme = "std"
# The command to use for shutting down the VM
shutdown_command = "sudo /sbin/poweroff"
# The path to the SSH private key Packer should use when setting up communication with the build VM"
ssh_private_key = "../../common/keys/vagrant"
# The SSH user Packer should use when setting up communication with the build VM
ssh_username = "packer"
# The Vagrant Cloud organisation to use when uploading the Vagrant Box
vagrant_cloud_org = "foosite"
# The user configurable portion of the Vagrant box release string
vagrant_cloud_revision = "0"
# The directory containing Vagrantfile snippets used to configure settings in the resultant Vagrant box
vagrantfile_base_dir = "vagrantfiles"
# The prefix used for Vagrantfile snippets
vagrantfile_filename_prefix = "Vagrantfile"
# The path Packer should upload the 'zero free space' script to within the build VM
zero_script_upload_path = "/tmp/zero-free-space.sh"
