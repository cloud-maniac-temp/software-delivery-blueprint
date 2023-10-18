# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module "create-fleet-scope" {
  source = "git::https://github.com/cloud-maniac-temp/terraform-modules.git//fleet-scope/render"
  git_org = var.git_org
  git_user = var.git_user
  git_email = var.git_email
  fleet_scope_repo = var.fleet_scope_repo
  fleet_scope = var.fleet_scope
  member_list = var.members
  users = var.users
  git_token = var.git_token
}

resource "null_resource" "set-landing-zone" {

  //The trigger is set to timestamp as we want the script to refresh LZ everytime tf is run. This will be helpful in cases this script fails and we need to run terraform again.
  //If we do not use timestamp, the script will not execute on tf rerun as it would only run on create.
  //The script handles change conditions gracefully and if it is just a tf run without any changes to LZ files, it will not update the LZ
  triggers = {
    timestamp = timestamp()
  }
  provisioner "local-exec" {
    when    = create
    command = "${path.module}/createLandingZone.sh ${var.git_user} ${var.git_email} ${var.git_token} ${var.git_org} ${var.acm_repo} ${var.app_name} ${var.gsa} ${var.env} ${var.ksa} ${var.cicd_sa} ${var.fleet_scope}"
    interpreter = [
      "/bin/sh",
    "-c"]
  }
  depends_on = [module.create-fleet-scope]
}
resource "google_service_account_iam_member" "update-workload-identity" {
  service_account_id = var.gsa
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gke_project_id}.svc.id.goog[${var.app_name}/${var.app_name}-sa]"
  depends_on         = [null_resource.set-landing-zone]
}

#Add the kubernetes service account created via ACM in secret manager
resource "google_secret_manager_secret" "ksa-secret" {
  secret_id = "${var.env}-kubernetes-sa"
  replication {
    auto {}
  }
  project = var.project_id
}
resource "google_secret_manager_secret_version" "ksa-secret-val" {
  secret      = google_secret_manager_secret.ksa-secret.id
  secret_data = var.ksa
}

resource "google_secret_manager_secret_iam_member" "ksa-secret-access" {
  secret_id = google_secret_manager_secret.ksa-secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cicd_sa}"
}

#Add the namespace created via ACM in secret manager
resource "google_secret_manager_secret" "namespace-secret" {
  secret_id = "${var.env}-namespace"
  replication {
    auto {}
  }
  project = var.project_id
}
resource "google_secret_manager_secret_version" "namespace-secret-val" {
  secret      = google_secret_manager_secret.namespace-secret.id
  secret_data = var.namespace
}

resource "google_secret_manager_secret_iam_member" "namespace-secret-access" {
  secret_id = google_secret_manager_secret.namespace-secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cicd_sa}"
}
