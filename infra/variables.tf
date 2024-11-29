variable "one_endpoint"  {
    description = "Open Nebula endpoint URL"
}
variable "one_username"  {
    description = "Open Nebula username"
}
variable "one_password"  {
    description = "Open Nebula login token"
}


variable "vm_admin_user" {
  description = "Admin user of VMs"
  default = "appuser"
}

variable "vm_app_count" {
  description = "Number of VM app instances to create"
  default     = 2
}

variable "vm_imagedatastore_id" {
    description = "Open Nebula datastore ID"
    default = 101 # => "nuada_pool"
}
variable "vm_network_id" {
    description = "ID of the virtual network to attach to the virtual machine"
    default = 3 # => "vlan173"
}

variable "vm_ssh_privkey_path" {
  description = "SSH private key path"
}
variable "vm_ssh_pubkey" {
    description = "SSH public key used for login as root into the VM instance"
}

variable "vm_image_name" {
    description = "VM OS image name"
    default = "Ubuntu Minimal 24.04"
}
variable "vm_image_url"  {
    description = "VM OS image URL"
    default = "https://marketplace.opennebula.io//appliance/44077b30-f431-013c-b66a-7875a4a4f528/download/0"
}

variable "vm_node_init_log" {
    description = "Node initialization log file"
    default = "/var/log/node-init.log"
}