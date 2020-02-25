variable "image" {
  default = "CADES_Ubuntu18.04_v20200126_1"
}

variable "flavor" {
  default = "m1.tiny"
}

variable "ssh_key_file" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_user_name" {
  default = "cades"
}

variable "network_name" {
  default = "or_provider_general_extnetwork1"
}

variable "node_count" {
  default = 2
}
