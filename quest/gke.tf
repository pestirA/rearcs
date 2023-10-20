terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}


provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Create the GKE cluster
resource "google_container_cluster" "my-rearcs-cluster" {
  name                = "my-rearcs-cluster"
  location            = var.location
  deletion_protection = false

  # Add other cluster configuration here.
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

}

# Separately Managed Node Pool
resource "google_container_node_pool" "my-node-rearc-pool" {
  name       = "my-node-rearc-pool"
  location   = var.location
  cluster    = google_container_cluster.my-rearcs-cluster.name
  node_count = 1

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]

    labels = {
      env = var.PROJECT_ID
    }

    # preemptible  = true
    machine_type = "e2-medium" //"e2-micro"
    //tags         = ["gke-node", "${var.PROJECT_ID}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

/*Run a null resource to setup context and also get the cluster credentials in kube config?*/
resource "null_resource" "kube-context" {

  provisioner "local-exec" {
    working_dir = path.module
    command     = <<EOT
    gcloud container clusters get-credentials ${var.name} --region ${var.region} --project ${var.PROJECT_ID}
    kubectl config set-context --current --namespace=default

   EOT
  }
  depends_on = [google_container_node_pool.my-node-rearc-pool]
}

# Setup a deployment
resource "kubernetes_deployment" "quest" {
  #depends_on = [google_container_node_pool.my-node-rearc-pool]
  depends_on = [null_resource.kube-context]
  metadata {
    name = "quest-example"
    /*namespace = kubernetes_namespace.kn-quest-namespace.metadata.0.name*/
    labels = {
      app = "quest"
      env = var.PROJECT_ID
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "quest"
        env = var.PROJECT_ID
      }
    }

    template {
      metadata {
        labels = {
          app = "quest"
          env = var.PROJECT_ID
        }
      }

      spec {
        container {
          image = "us-central1-docker.pkg.dev/${var.PROJECT_ID}/artifacts/abishaiep/quests:version1.0" //"quests:version1.0" //"quest-*" //"abishaiep/quests"
          name  = "quest"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "quest" {
  #depends_on = [kubernetes_deployment.quest]
  metadata {
    name = "quest-example" //"quest-example"
  }
  spec {
    selector = {
      app = kubernetes_pod.quest.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 3000
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_pod" "quest" {
  #depends_on = [kubernetes_deployment.quest]
  metadata {
    name = "quest-example"
    labels = {
      app = "quest" //"MyApp"
      env = var.PROJECT_ID
    }
  }

  spec {
    container {
      image = "us-central1-docker.pkg.dev/${var.PROJECT_ID}/artifacts/abishaiep/quests:version1.0" //"quests:version1.0" //"us-central1-docker.pkg.dev/humble-being-293400/artifacts/abishaiep/quests@sha256:eccd46aa2e81e84624567d52cd4f225f5103777e6001c2e5852788b89da29da6" //"abishaiep/quests:1.0" //
      name  = "quest"                                                                              //"quests"                                                                               //"quest"                                                                                //"quest"
    }
  }
}
