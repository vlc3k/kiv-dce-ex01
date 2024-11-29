terraform {
  required_providers {
    opennebula = {
      source = "OpenNebula/opennebula"
      version = "0.4.3"
    }
  }
}

provider "opennebula" {
  endpoint      = "${var.one_endpoint}"
  username      = "${var.one_username}"
  password      = "${var.one_password}"
}

resource "opennebula_image" "os-image" {
    name = "${var.vm_image_name}"
    datastore_id = "${var.vm_imagedatastore_id}"
    persistent = false
    path = "${var.vm_image_url}"
    permissions = "600"
}

resource "opennebula_virtual_machine" "app-vm" {  
  count = 2
  name = "dce-app-vm-${count.index + 1}"
  description = "App (backend) VM #${count.index + 1}"
  cpu = 2
  vcpu = 2
  memory = 2048
  permissions = "600"
  group = "users"

  context = {
    NETWORK  = "YES"
    HOSTNAME = "$NAME"
    SSH_PUBLIC_KEY = "${var.vm_ssh_pubkey}"
  }

  os {
    arch = "x86_64"
    boot = "disk0"
  }
  
  disk {
    image_id = opennebula_image.os-image.id
    target   = "vda"
    size     = 10000 # 10GB
  }

  graphics {
    listen = "0.0.0.0"
    type   = "vnc"
  }

  nic {
    network_id = var.vm_network_id
  }

  connection {
    type = "ssh"
    user = "root"
    host = self.ip
    private_key = file(var.vm_ssh_privkey_path)
  }

  provisioner "file" {
    source = "scripts/"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "export INIT_USER=${var.vm_admin_user}",
      "export INIT_PUBKEY='${var.vm_ssh_pubkey}'",
      "export INIT_HOSTNAME=${self.name}",
      "export INIT_LOG=${var.vm_node_init_log}",
      "touch ${var.vm_node_init_log}",
      "sh /tmp/vm-init.sh"
    ]
  }

  tags = {
    role = "app"
  }
}
  

resource "opennebula_virtual_machine" "loadbalancer-vm" {  
  count = 1
  name = "dce-loadbalancer-vm-${count.index + 1}"
  description = "Loadbalancer VM #${count.index + 1}"
  cpu = 2
  vcpu = 2
  memory = 2048
  permissions = "600"
  group = "users"

  context = {
    NETWORK  = "YES"
    HOSTNAME = "$NAME"
    SSH_PUBLIC_KEY = "${var.vm_ssh_pubkey}"
  }

  os {
    arch = "x86_64"
    boot = "disk0"
  }
  
  disk {
    image_id = opennebula_image.os-image.id
    target   = "vda"
    size     = 10000 # 10GB
  }

  graphics {
    listen = "0.0.0.0"
    type   = "vnc"
  }

  nic {
    network_id = var.vm_network_id
  }

  connection {
    type = "ssh"
    user = "root"
    host = self.ip
    private_key = file(var.vm_ssh_privkey_path)
  }

  provisioner "file" {
    source = "scripts/"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "export INIT_USER=${var.vm_admin_user}",
      "export INIT_PUBKEY='${var.vm_ssh_pubkey}'",
      "export INIT_HOSTNAME=${self.name}",
      "export INIT_LOG=${var.vm_node_init_log}",
      "touch ${var.vm_node_init_log}",
      "sh /tmp/vm-init.sh"
    ]
  }

  tags = {
    role = "loadbalancer"
  }
}


#-------OUTPUTS ------------

output "app_vm" {
  value = opennebula_virtual_machine.app-vm.*.ip
}

output "loadbalancer_vm" {
  value = opennebula_virtual_machine.loadbalancer-vm.*.ip
}


resource "local_file" "hosts_cfg" {
  content = templatefile("inventory.tmpl",
    {
      vm_admin_user = var.vm_admin_user,
      app_nodes = opennebula_virtual_machine.app-vm.*.ip,
      loadbalancer_nodes = opennebula_virtual_machine.loadbalancer-vm.*.ip
    })
  filename = "./ansible/inventory.ini"
}

#
# EOF
#
