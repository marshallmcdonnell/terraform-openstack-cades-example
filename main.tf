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
  count = 2

  network {
    name = var.network_name 
  }
}
