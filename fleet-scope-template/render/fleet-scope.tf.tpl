data "google_secret_manager_secret_version" "gke" {
  secret = "gke-${var.env}"
  project = var.secret_project_id
}

data "google_secret_manager_secret_version" "membership-id" {
  secret = "membership-id-${env}"
  project = var.secret_project_id
}

data "google_secret_manager_secret_version" "membership-project" {
  secret = "membership-project-${var.env}"
  project = var.secret_project_id
}

resource "google_gke_hub_scope" "fleet-scope" {
  scope_id = YOUR_NAMESPACE
  project = google_secret_manager_secret_version.membership-project.secret_data
}

resource "google_gke_hub_namespace" "fleet-ns" {
  scope_namespace_id = YOUR_NAMESPACE
  scope_id = google_gke_hub_scope.fleet-scope.scope_id
  scope = google_gke_hub_scope.fleet-scope.name
  project = google_secret_manager_secret_version.membership-project.secret_data
}

resource "google_gke_hub_scope_iam_binding" "scope-iam-binding" {
  project = google_gke_hub_scope.fleet-scope.project
  scope_id = google_gke_hub_scope.fleet-scope.scope_id
  role = "roles/viewer"
  members = [
    MEMBERS_LIST
  ]
}

resource "google_gke_hub_membership_binding" "membership-binding" {
  membership_binding_id = YOUR_NAMESPACE
  scope = google_gke_hub_scope.fleet-scope.name
  membership_id = google_secret_manager_secret_version.membership.secret_data
  location = "global"
  project = google_secret_manager_secret_version.membership-project.secret_data
}

resource "google_gke_hub_scope_rbac_role_binding" "rbac-role-binding" {
  scope_rbac_role_binding_id = YOUR_NAMESPACE
  scope_id = google_gke_hub_scope.fleet-scope.scope_id
  user = YOUR_USERS
  role {
    predefined_role = "VIEW"
  }
  project = google_secret_manager_secret_version.membership-project.secret_data
}