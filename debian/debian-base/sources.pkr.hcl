source "virtualbox-iso" "debian" {
  boot_command = [
    "<esc><wait>",
    "install <wait>",
    "auto <wait>",
    "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed-${var.part_scheme}.cfg <wait>",
    "debian-installer=en_GB <wait>",
    "locale=en_GB <wait>",
    "keymap=uk <wait>",
    "hostname=localhost <wait>",
    "domain=localdomain <wait>",
    "<enter>"
  ]
  boot_wait            = "${var.installer_boot_time}"
  communicator         = "${var.communicator}"
  cpus                 = "${var.cpu_count}"
  disk_size            = "${var.disk_size}"
  export_opts          = ["--ovf20"]
  gfx_controller       = "${var.gfx_controller}"
  gfx_vram_size        = "${var.gfx_vram_size}"
  guest_additions_mode = "upload"
  guest_additions_path = "${var.guest_additions_path}"
  guest_os_type        = "${var.guest_os_type}"
  hard_drive_interface = "sata"
  headless             = "${var.headless}"
  http_directory       = "../common/http"
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.memory_size}"
  output_directory     = "output-${var.template}-${var.part_scheme}-${source.type}"
  shutdown_command     = "${var.shutdown_command}"
  sound                = "none"
  ssh_private_key_file = "${var.ssh_private_key}"
  ssh_timeout          = "10000s"
  ssh_username         = "${var.ssh_username}"
  usb                  = false
  vboxmanage           = [
    ["modifyvm", "{{ .Name }}", "--nat-localhostreachable1", "on"],
    ["setextradata", "global", "GUI/SuppressMessages", "all"]
  ]
  vm_name              = "${var.template}-${source.type}"
}
