# Criar um serviço do Cloud Run
resource "google_cloud_run_service" "app_pesquisa" {
  name     = var.app_name_run
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/${var.app_name_run}:latest"
      }
      service_account_name = google_service_account.pesquisa_account.email
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

resource "google_cloudbuild_trigger" "github_trigger" {
  name = "trigger-pesquisa"

  github {
    owner        = var.github_owner
    name         = var.github_repo
    push {
      branch = "main"
    }
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build", "-t", "gcr.io/${var.project_id}/${var.app_name_run}:$COMMIT_SHA", "."
      ]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push", "gcr.io/${var.project_id}/${var.app_name_run}:$COMMIT_SHA"
      ]
    }
    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = [
        "run", "deploy", var.app_name_run,
        "--image", "gcr.io/${var.project_id}/${var.app_name_run}:$COMMIT_SHA",
        "--region", var.region,
        "--platform", "managed",
        "--allow-unauthenticated",
        "--service-account", google_service_account.pesquisa_account.email
      ]
    }
    substitutions = {
      _SERVICE_NAME = var.app_name_run
      _REGION       = var.region
    }
    timeout = "1200s"
  }
}
