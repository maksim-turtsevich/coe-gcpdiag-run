resource "google_service_account" "gcpdiag-build-se" {
  account_id   = "gcpdiag-build-se-terraform"
  display_name = "Cloud Build service account for gcpdiag"
}

resource "google_project_iam_member" "gcpdiag-build-se-role" {
  project  = var.project-id
  for_each = var.cloud-build-roles
  role     = each.value
  member   = "serviceAccount:${google_service_account.gcpdiag-build-se.email}"
}

resource "google_service_account" "gcpdiag-run-se" {
  account_id   = "gcpdiag-run-se-terraform"
  display_name = "Service Account for gcpdiag running in Cloud Run"
}

resource "google_project_iam_member" "gcpdiag-run-se-role" {
  project  = var.project-id
  for_each = var.gcpdiag-roles
  role     = each.value
  member   = "serviceAccount:${google_service_account.gcpdiag-run-se.email}"
}



resource "google_cloudbuild_trigger" "gcpdiag-build-trigger" {
  name            = "gcpdiag-trigger-terraform"
  description     = "Build trigger for gcpdiag managed by terraform"
  service_account = google_service_account.gcpdiag-build-se.id

  github {
    owner = "maksim-turtsevich"
    name  = "gcpdiag"

    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"
}

resource "google_cloud_run_service" "gcpdiag_service" {
  name     = "gcpdiag-prod"
  location = var.region

  traffic {
    percent         = 100
    latest_revision = true
  }

  template {
    spec {
      containers {
        image = "gcr.io/gcp-coe-msp-sandbox/gcpdiag:latest"
        ports {
          container_port = 8000
        }
        env {
          name = "jira_token"
          value_from {
            secret_key_ref {
              key  = 2
              name = "jira-token"
            }
          }
        }
        resources {
          limits = {
            "memory" = "4Gi" 
            "cpu" = 2
          }
        }
      }
      service_account_name = google_service_account.gcpdiag-run-se.email
    }
  }
  depends_on = [
    google_project_iam_member.gcpdiag-run-se-role
  ]
}

resource "google_cloud_run_service_iam_member" "member" {
  location = google_cloud_run_service.gcpdiag_service.location
  project  = google_cloud_run_service.gcpdiag_service.project
  service  = google_cloud_run_service.gcpdiag_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

