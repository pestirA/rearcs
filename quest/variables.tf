variable "project" {
  default     = "humble-being-293400"
  description = "the google cloud project"
}

variable "PROJECT_ID" {
  default     = "humble-being-293400"
  description = "the google cloud project"
}

variable "name" {
  default     = "my-rearcs-cluster"
  description = "the google cloud gke cluster name"
}

variable "location" {
  default     = "us-central1"
  description = "the google cloud default location"
}

variable "region" {
  default     = "us-central1"
  description = "the google cloud default region"
}

variable "IMAGE_NAME" {
  default     = "quests"
  description = "the target image name"
}

variable "image" {
  default     = "quests"
  description = "the target image in the gcr path e.g gcr.io/PROJECT_ID/IMAGE_NAME"
}

/*
variable "google_region" {
  default=
  description = "The Google Cloud region to use"
}

variable "google_zone" {
  default=   
  description = "The Google Cloud zone to use"
}

variable "domain_name" {
  default=  
  description = "The domain name to use"
}*/