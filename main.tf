resource "openstack_compute_keypair_v2" "my-cloud-key" {
    name = "cades"
}

resource "openstack_compute_instance_v2" "my-cloud-instance" {
  name            = "test-vm-${count.index}"
  image_name      = "CADES_Ubuntu18.04_v20200126_1"
  flavor_name     = "m1.tiny"
  key_pair        = openstack_compute_keypair_v2.my-cloud-key.name
  security_groups = ["default"]
  count = 2

  network {
    name = "or_provider_general_extnetwork1"
  }
}
