provider "google" {
  credentials = file("/Users/pestirai/zdemo/google-cloud-creds/credentials.json")
  project     = var.project
  region      = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
/*
provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
  #server_url = "https://acme-v02.api.letsencrypt.org/directory"
}*/

provider "tls" {}