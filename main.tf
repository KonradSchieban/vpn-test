resource "google_compute_network" "vpc_a" {
  name                    = var.vpc_a_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_a_subnet" {
  name          = "${var.vpc_a_name}-subnet"
  ip_cidr_range = var.vpc_a_subnet_cidr
  network       = google_compute_network.vpc_a.self_link
  region        = var.region
}

resource "google_compute_network" "vpc_b" {
  name                    = var.vpc_b_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_b_subnet" {
  name          = "${var.vpc_b_name}-subnet"
  ip_cidr_range = var.vpc_b_subnet_cidr
  network       = google_compute_network.vpc_b.self_link
  region        = var.region
}
 
/*
module "vpn_ha" {
  source  = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/net-vpn-ha"
  project_id = var.project_id
  region1    = var.region
  network1   = google_compute_network.vpc_a.name
  region2    = var.region
  network2   = google_compute_network.vpc_b.name
  name       = "vpn-a-to-b"

  router_config = {
    "router-a" = {
      asn = 64512
      region = var.region
    },
    "router-b" = {
      asn = 64513
      region = var.region
    }
  }
}
*/

resource "google_compute_firewall" "allow_internal_a" {
  name    = "allow-internal-a"
  network = google_compute_network.vpc_a.name
  allow {
    protocol = "all"
  }
  source_ranges = [google_compute_subnetwork.vpc_b_subnet.ip_cidr_range]
}

resource "google_compute_firewall" "allow_internal_b" {
  name    = "allow-internal-b"
  network = google_compute_network.vpc_b.name
  allow {
    protocol = "all"
  }
  source_ranges = [google_compute_subnetwork.vpc_a_subnet.ip_cidr_range]
}
