# Criar um serviço do Cloud Run
resource "google_cloud_run_service" "app_pesquisa" {
  name     = var.app_name_run
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/app-image:latest"
      }
    }
  }

  autogenerate_revision_name = true
}

resource "google_cloud_run_service_iam_member" "pesquisa_invover" {
  location = google_cloud_run_service.app_pesquisa.location
  project  = google_cloud_run_service.app_pesquisa.project
  service  = google_cloud_run_service.app_pesquisa.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.pesquisa_account.email}"
}

# Criar um gatilho no Cloud Build
resource "google_cloudbuild_trigger" "github_trigger" {
  name = "github-trigger"

  github {
    owner = "Marcus-Holanda777"
    name  = "https://github.com/Marcus-Holanda777/ingestion-google-drive"
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"
}
