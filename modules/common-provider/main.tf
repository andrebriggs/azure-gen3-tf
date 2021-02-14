# terraform {
#   required_version = "~> 0.12.6"
# }

terraform {
  required_providers {
    random = {
      source = "random"
      version = ">=2.1"
    }
    null = {
      source = "null"
      version = ">=2.1.2"
    }
    external = {
      source = "external"
      version = ">=1.2"
    }
    local = {
      source = "local"
      version = ">=1.4"
    }
  }
}

# provider "null" {
#   version = "~>2.1.2"
# }

# provider "random" {
#   version = "~> 2.1"
# }

# provider "external" {
#   version = "~> 1.2"
# }

# provider "local" {
#   version = "~> 1.4"
# }
