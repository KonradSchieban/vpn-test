output "vpc_a_name" {
  value = google_compute_network.vpc_a.name
}

output "vpc_b_name" {
  value = google_compute_network.vpc_b.name
}

output "vpn_name" {
  value = module.vpn_ha.name
}
