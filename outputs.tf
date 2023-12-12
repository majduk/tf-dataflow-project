/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  tfvars = {
    project_id     	= module.data_project.project_id
    worker_sa      	= google_service_account.dataflow_sa.email
    automation_sa      	= google_service_account.automation_sa.email
    network_self_link   = module.vpc.network_self_link
    subnetwork_self_link= module.vpc.subnets_self_links[0]
    tmp_dir_bucket 	= google_storage_bucket.tmp_dir_bucket.name
    tfstate_bucket 	= google_storage_bucket.tfstate_bucket.name
    region   	 	= var.region
  }
}

resource "local_file" "tfvars" {
  file_permission = "0644"
  filename        = "${try(pathexpand(var.outputs_location), "")}/project.tfvars.json"
  content         = jsonencode(local.tfvars)
}
