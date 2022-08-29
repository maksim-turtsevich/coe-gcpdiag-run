variable "project-id" {
  type    = string
  default = "gcp-coe-msp-sandbox"
}

variable "region" {
  type    = string
  default = "europe-central2"
}

variable "cloud-build-roles" {
  type    = set(string)
  default = ["roles/cloudbuild.builds.builder", "roles/run.admin", "roles/iam.serviceAccountUser", "roles/secretmanager.secretAccessor"]
}

variable "gcpdiag-roles" {
  type = set(string)
  default = ["roles/secretmanager.secretAccessor", "roles/serviceusage.serviceUsageConsumer",
  "roles/viewer"]
}

# variable "roles" {
#     type = map(set(string))
#     default = {
#         "cloud-build" = ["roles/cloudbuild.builds.builder", "roles/run.admin"]
#         "gcpdiag" = ["roles/secretmanager.secretAccessor", "roles/serviceusage.serviceUsageConsumer", "roles/viewer"]
#     }
# }