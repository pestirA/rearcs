/* Artifact Registry Repository Docker - Create a Google Cloud Artifact Registry repository */
resource "google_artifact_registry_repository" "my-repo" {
  location = var.location
  #repository_id = var.PROJECT_ID
  repository_id = "artifacts"
  description   = "example docker repository"
  format        = "DOCKER"
  docker_config {
    immutable_tags = true
  }
}

# Updated -Build and push the Docker image to Artifact Registry using the local provisioner
resource "null_resource" "docker-registry" {

  provisioner "local-exec" {
    working_dir = path.module
    command     = <<EOT
    gcloud builds submit --config=cloudbuild.yaml
   EOT
  }
  depends_on = [google_artifact_registry_repository.my-repo]
}
