terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }

  backend "s3" {
    bucket       = "tgstation-infrastructure-tofu-state"
    key          = "tofu.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }

  encryption {
    key_provider "pbkdf2" "passphrase" {
      passphrase = var.state_passphrase
    }
    method "aes_gcm" "passphrase" {
      keys = key_provider.pbkdf2.passphrase
    }
    state {
      method   = method.aes_gcm.passphrase
      enforced = true
    }
    plan {
      method   = method.aes_gcm.passphrase
      enforced = true
    }
  }
}

variable "state_passphrase" {
  type      = string
  sensitive = true
}

provider "aws" {
  region = "us-east-1"
}

provider "cloudflare" {}
