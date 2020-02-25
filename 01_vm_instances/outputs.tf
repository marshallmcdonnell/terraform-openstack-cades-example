output "node_private_address" {
  value = [openstack_compute_instance_v2.node.*.access_ip_v4]
}
