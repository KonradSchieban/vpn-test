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

module "vpn-1" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/net-vpn-ha"
  project_id = var.project_id
  region     = var.region
  network    = google_compute_network.vpc_a.self_link
  name       = "net1-to-net-2"
  peer_gateways = {
    default = { gcp = module.vpn-2.self_link }
  }
  router_config = {
    asn = 64514
  }
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.1"
        asn     = 64513
        md5_authentication_key = {
          name = "foo"
          key  = "bar"
        }
      }
      bgp_session_range     = "169.254.1.2/30"
      vpn_gateway_interface = 0
      shared_secret         = "mySecret"
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.2.1"
        asn     = 64513
        md5_authentication_key = {
          name = "foo2"
          key  = "bar2"
        }
      }
      bgp_session_range     = "169.254.2.2/30"
      vpn_gateway_interface = 1
      shared_secret         = "mySecret"
    }
  }
}

module "vpn-2" {
  source        = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/net-vpn-ha"
  project_id    = var.project_id
  region        = var.region
  network       = google_compute_network.vpc_b.self_link
  name          = "net2-to-net1"
  router_config = { asn = 64513 }
  peer_gateways = {
    default = { gcp = module.vpn-1.self_link }
  }
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.2"
        asn     = 64514
        md5_authentication_key = {
          name = "foo"
          key  = "bar"
        }
      }
      bgp_session_range     = "169.254.1.1/30"
      shared_secret         = module.vpn-1.shared_secrets["remote-0"]
      vpn_gateway_interface = 0
      shared_secret         = "mySecret"
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.2.2"
        asn     = 64514
        md5_authentication_key = {
          name = "foo2"
          key  = "bar2"
        }
      }
      bgp_session_range     = "169.254.2.1/30"
      shared_secret         = module.vpn-1.shared_secrets["remote-1"]
      vpn_gateway_interface = 1
      shared_secret         = "mySecret"
    }
  }
}

/* -------------- */
/* FW Rules below */

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

resource "google_compute_firewall" "allow_iap_a" {
  name    = "allow-iap-a"
  network = google_compute_network.vpc_a.name

  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["allow-iap"]
}

resource "google_compute_firewall" "allow_iap_b" {
  name    = "allow-iap-b"
  network = google_compute_network.vpc_b.name

  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["allow-iap"]
}
