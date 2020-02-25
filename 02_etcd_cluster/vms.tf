resource "openstack_compute_keypair_v2" "key" {
  name = "cades"
  public_key = file("${var.ssh_key_file}.pub")
}

resource "openstack_compute_instance_v2" "node" {
  name            = "test-vm-${count.index}"
  image_name      = var.image
  flavor_name     = var.flavor
  key_pair        = openstack_compute_keypair_v2.key.name
  security_groups = ["default"]
  count = var.node_count 

  network {
    name = var.network_name 
  }

  connection {
    user = var.ssh_user_name
    host = self.access_ip_v4
  }

  provisioner "file" {
    source = "setup_etcd_ubuntu.sh"
    destination = "setup_etcd_ubuntu.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "pwd",
      "ls",
      "bash setup_etcd_ubuntu.sh",
    ]
    on_failure = fail
  }
}
