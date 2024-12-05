resource "google_storage_bucket" "storage_pesquisa" {
  name          = var.bucket_name
  location      = var.region
  project       = var.project_id
  force_destroy = true

  storage_class            = "STANDARD"
  public_access_prevention = "enforced"

  soft_delete_policy {
    retention_duration_seconds = 0
  }
}

resource "google_storage_bucket_iam_member" "pesquisa_access" {
  bucket = google_storage_bucket.storage_pesquisa.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.pesquisa_account.email}"
}