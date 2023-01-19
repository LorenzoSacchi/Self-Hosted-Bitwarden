terraform {
  required_version = "~> 1.3.4"
  required_providers {
    linode = {
      source = "linode/linode"
    }
  }
}

provider "linode" {
  token = var.linode_token
} 


resource "linode_instance" "bitwarden-instance" {
  label = "bitwarden"
  image = "linode/ubuntu22.10"
  region = "eu-central"
  type = "g6-nanode-1"
  root_pass = var.root_password
  tags = ["vault"]

group = "vault"

  interface {
    purpose ="public"
  }
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
  name = "personalvault"
  domain_id = linode_domain.lorenzosacchi-dns.id
  record_type = "A"
  target = tolist(linode_instance.bitwarden-instance.ipv4)[0]

  depends_on = [
    linode_domain.lorenzosacchi-dns
  ]

}

resource "linode_domain_record" "bitwarden-dns-record-ipv6" {
  name = "personalvault"
  domain_id = linode_domain.lorenzosacchi-dns.id
  record_type = "AAAA"
  target = split("/",tolist([linode_instance.bitwarden-instance.ipv6])[0])[0]

  depends_on = [
    linode_domain.lorenzosacchi-dns
  ]

}

resource "linode_firewall" "bitwarden-firewall"{
  label = "bitwarden-firewall"

  inbound_policy = "DROP"

  inbound {
    label    = "allow-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  outbound_policy = "ACCEPT"

  linodes = [linode_instance.bitwarden-instance.id]

  depends_on = [
    linode_instance.bitwarden-instance
  ]

}
