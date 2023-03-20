packer {
  required_plugins {
    virtualbox = {
      version = "~> 1.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = "~> 1.0.1"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}
