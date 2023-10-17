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

locals {
  mem_list = join(",", var.member_list)
}


resource "null_resource" "fleet_scope_renderer" {
  triggers = {
    timestamp = timestamp()
  }
  provisioner "local-exec" {
    when    = create
    command = "${path.module}/create_fleet_scope.sh ${var.git_org} ${var.git_user} ${var.git_email} ${var.git_token} ${var.fleet_scope_repo} ${var.fleet_scope} ${local.mem_list} ${var.users}"
  }

}