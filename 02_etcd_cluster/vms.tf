resource "openstack_compute_keypair_v2" "key" {
  name = "cades"
  public_key = file("${var.ssh_key_file}.pub")
}

resource "null_resource" "get_discovery_key" {
  provisioner "local-exec" {
    command = "curl https://discovery.etcd.io/new?size=${var.node_count} >> discovery_key.txt"
  }
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

  provisioner "file" {
    source = "discovery_key.txt"
    destination = "discovery_key.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "bash setup_etcd_ubuntu.sh ${self.name} ${self.access_ip_v4} "
    ]
    on_failure = fail
  }
}
