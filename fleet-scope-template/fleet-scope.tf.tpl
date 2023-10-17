/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

data "google_secret_manager_secret_version" "gke" {
  secret = "gke-${var.env}"
  project = var.secrets_project_id
}

data "google_secret_manager_secret_version" "membership-name" {
  secret = "membership-name-${var.env}"
  project = var.secrets_project_id
}

data "google_secret_manager_secret_version" "membership-project" {
  secret = "membership-project-${var.env}"
  project = var.secrets_project_id
}

resource "google_gke_hub_scope" "fleet-scope" {
  scope_id = "YOUR_FLEET_SCOPE"
  project = data.google_secret_manager_secret_version.membership-project.secret_data
}

resource "google_gke_hub_namespace" "fleet-ns" {
  scope_namespace_id = "YOUR_FLEET_SCOPE"
  scope_id = google_gke_hub_scope.fleet-scope.scope_id
  scope = google_gke_hub_scope.fleet-scope.name
  project = data.google_secret_manager_secret_version.membership-project.secret_data
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
  membership_binding_id = "YOUR_FLEET_SCOPE"
  scope = google_gke_hub_scope.fleet-scope.name
  membership_id = data.google_secret_manager_secret_version.membership-name.secret_data
  location = "global"
  project = data.google_secret_manager_secret_version.membership-project.secret_data
}

resource "google_gke_hub_scope_rbac_role_binding" "rbac-role-binding" {
  scope_rbac_role_binding_id = "YOUR_FLEET_SCOPE"
  scope_id = google_gke_hub_scope.fleet-scope.scope_id
  user = "YOUR_USERS"
  role {
    predefined_role = "VIEW"
  }
  project = data.google_secret_manager_secret_version.membership-project.secret_data
}