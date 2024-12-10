resource "google_project_iam_member" "cloud_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.pesquisa_account.email}"
}

resource "google_project_iam_member" "cloud_build_editor" {
  project = "<SEU_PROJETO>"
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.pesquisa_account.email}"
}

resource "google_project_iam_member" "service_account_user" {
  project = "<SEU_PROJETO>"
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.pesquisa_account.email}"
}

resource "google_project_iam_member" "artifact_registry_admin" {
  project = "<SEU_PROJETO>"
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.pesquisa_account.email}"
}

resource "google_cloudbuild_trigger" "github_trigger" {
  project         = var.project_id
  name            = "trigger-pesquisa"
  location        = var.region
  service_account = google_service_account.pesquisa_account.id
  description     = "trigger do app pesquisa de mercado"

  github {
    owner = var.github_owner
    name  = var.github_repo
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
    timeout     = "1200s"
    logs_bucket = "gs://${var.bucket_name}"
    options {
      logging = "GCS_ONLY"
    }
  }
}
