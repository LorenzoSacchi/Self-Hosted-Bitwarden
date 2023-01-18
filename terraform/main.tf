terraform {
    required_version = "~> 1.3.6"
    required_providers {
      linode = {
        source = "linode/linode"
      }
    }
}

provider "linode" {
    config_path = vars/linode
    config_profile = personal
} 