resource "google_service_account" "pesquisa_account" {
  account_id   = var.bucket_name
  display_name = "recebe r"
}

resource "google_service_account_key" "pesquisa_account_key" {
  service_account_id = google_service_account.pesquisa_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

resource "local_file" "pesquisa_account_key_file" {
  content  = base64decode(google_service_account_key.pesquisa_account_key.private_key)
  filename = "${path.module}/${var.project_id}_${var.bucket_name}.json"
}