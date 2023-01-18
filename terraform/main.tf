terraform {
  required_version = "~> 1.3.4"
  required_providers {
    linode = {
      source = "linode/linode"
    }
  }
}

provider "linode" {
  config_path = "vars/linode"
  config_profile = "personal"
} 


resource "linode_instances" "bitwarden-instance" {

}


resource "linode_domain" "lorenzosacchi-dns" {
  domain = var.domain_entry
  type = "master"
  soa_email = var.soa_email_entry

  depends_on = [
    linode_instance.bitwarden-instance
  ]
}


resource "linode_domain_record" "bitwarden-dns-record-ipv4" {
  name = "bitwarden"
  domain_id = linode_domain.lorenzosacchi-dns.id
  type = "A"
  target = linode_instances.bitwarden-instance.ipv4
}

resource "linode_domain_record" "bitwarden-dns-record-ipv6" {
  name = "bitwarden"
  domain_id = linode_domain.lorenzosacchi-dns.id
  type = "AAAA"
  target = linode_instances.bitwarden-instance.ipv6
}

resource "linode_firewall" "bitwarden-firewall"{
  label = "bitwarden-firewall"

  inbound_policy = "DROP"

  inbound {
    label    = "allow-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = [linode_instances.bitwarden-instance.ipv4]
    ipv6     = [linode_instances.bitwarden-instance.ipv6]
  }

  inbound {
    label    = "allow-ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = [linode_instances.bitwarden-instance.ipv4]
    ipv6     = [linode_instances.bitwarden-instance.ipv6]
  }

  outbound_policy = "ACCEPT"

  linodes = [linode_instance.bitwarden-instance.id]
}

