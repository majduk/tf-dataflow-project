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
  activate_apis = [
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "dataflow.googleapis.com",
    "bigtableadmin.googleapis.com",
    "bigquery.googleapis.com",
    "datapipelines.googleapis.com",
    "cloudscheduler.googleapis.com",
  ]
  automation_sa_required_roles = [
    "roles/dataflow.admin",
    "roles/storage.admin",
    "roles/storage.objectAdmin",
    "roles/iam.serviceAccountUser"
  ]
  dataflow_sa_required_roles = [
    "roles/dataflow.worker",
    "roles/storage.objectAdmin",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser"
  ]
}

module "data_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 14.0"
  name                        = var.project_name
  folder_id                   = google_folder.parent.id
  org_id                      = var.org_id
  create_project_sa           = false
  billing_account             = var.billing_account
  activate_apis               = local.activate_apis
}

module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 7.0"
  project_id   = module.data_project.project_id
  network_name = "dataflow-network"

  subnets = [
    {
      subnet_name   = "dataflow-subnetwork"
      subnet_ip     = "10.1.3.0/24"
      subnet_region = var.region
      subnet_private_access = true
    },
  ]

  secondary_ranges = {
    dataflow-subnetwork = [
      {
        range_name    = "my-secondary-range"
        ip_cidr_range = "192.168.64.0/24"
      },
    ]
  }
  ingress_rules = [{
    name                    = "allow-dataflow-internal"
    description             = null
    priority                = null
    source_tags             = ["dataflow"]
    target_tags             = ["dataflow"]
    allow = [{
      protocol = "tcp"
      ports    = ["12345-12346"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]
}

resource "google_service_account" "dataflow_sa" {
  project      = module.data_project.project_id
  account_id   = "dataflow-sa"
  display_name = "dataflow-sa"
}

resource "google_project_iam_member" "dataflow_sa" {
  for_each = toset(local.dataflow_sa_required_roles)
  project = module.data_project.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.dataflow_sa.email}"
}

resource "google_service_account" "automation_sa" {
  project      = module.data_project.project_id
  account_id   = "automation-sa"
  display_name = "automation-sa"
}

resource "google_project_iam_member" "automation_sa" {
  for_each = toset(local.automation_sa_required_roles)
  project = module.data_project.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.automation_sa.email}"
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

locals {
  gcs_bucket_name = "tmp-dir-bucket-${random_id.random_suffix.hex}"
  tfstate_bucket_name = "tfstate-${random_id.random_suffix.hex}"
}

resource "google_storage_bucket" "tmp_dir_bucket" {
  name          = local.gcs_bucket_name
  location      = var.region
  storage_class = "REGIONAL"
  project       = module.data_project.project_id
  uniform_bucket_level_access = true
  force_destroy = true
}

resource "google_storage_bucket" "tfstate_bucket" {
  name          = local.tfstate_bucket_name
  location      = var.region
  storage_class = "REGIONAL"
  project       = module.data_project.project_id
  uniform_bucket_level_access = true
  force_destroy = true
}

resource "google_project_iam_custom_role" "gcp_bt_factory" {
  project     = module.data_project.project_id
  role_id     = "gcp_bt_factory"
  title       = "GCP Bigtable Factory"
  description = "GCP Bigtable factory role"
  permissions = [
                 "bigtable.appProfiles.get",
                 "bigtable.appProfiles.list",
                 "bigtable.clusters.get",
                 "bigtable.clusters.list",
                 "bigtable.instances.get",
                 "bigtable.instances.list",
                 "bigtable.locations.list",
                 "resourcemanager.projects.get",
                 "bigtable.clusters.create",
                 "bigtable.instances.create",
                 "bigtable.clusters.update",
                 "bigtable.instances.update",
                 "bigtable.appProfiles.create",
                 "bigtable.appProfiles.delete",
                 "bigtable.appProfiles.update",
                 "bigtable.clusters.delete",
                 "bigtable.instances.delete",
                 "bigtable.tables.get",
                 "bigtable.tables.create",
		 "bigtable.tables.update",
                 "bigtable.tables.delete",
                ]
}

resource "google_project_iam_member" "automation_sa_btf" {
  project = module.data_project.project_id
  role    = google_project_iam_custom_role.gcp_bt_factory.id
  member  = "serviceAccount:${google_service_account.automation_sa.email}"
}

resource "google_project_iam_custom_role" "gcp_bq_factory" {
  project     = module.data_project.project_id
  role_id     = "gcp_bq_factory"
  title       = "GCP Big Query Factory"
  description = "GCP Big Query factory role"
  permissions = [
                 "bigquery.dataPolicies.create",
                 "bigquery.dataPolicies.delete",
                 "bigquery.dataPolicies.get",
                 "bigquery.dataPolicies.list",
                 "bigquery.dataPolicies.update",
                 "bigquery.datasets.create",
                 "bigquery.datasets.createTagBinding",
                 "bigquery.datasets.delete",
                 "bigquery.datasets.deleteTagBinding",
                 "bigquery.datasets.get",
                 "bigquery.datasets.link",
                 "bigquery.datasets.listEffectiveTags",
                 "bigquery.datasets.listSharedDatasetUsage",
                 "bigquery.datasets.listTagBindings",
                 "bigquery.datasets.update",
                 "bigquery.datasets.updateTag",
                 "bigquery.rowAccessPolicies.create",
                 "bigquery.rowAccessPolicies.delete",
                 "bigquery.rowAccessPolicies.list",
                 "bigquery.rowAccessPolicies.update",
                 "bigquery.tables.create",
                 "bigquery.tables.createIndex",
                 "bigquery.tables.createSnapshot",
                 "bigquery.tables.delete",
                 "bigquery.tables.deleteIndex",
                 "bigquery.tables.deleteSnapshot",
                 "bigquery.tables.export",
                 "bigquery.tables.get",
                 "bigquery.tables.list",
                 "bigquery.tables.restoreSnapshot",
                 "bigquery.tables.setCategory",
                 "bigquery.tables.update",
                 "bigquery.tables.updateTag",
                 "resourcemanager.projects.get"
                ]
}

resource "google_project_iam_member" "automation_sa_bqf" {
  project = module.data_project.project_id
  role    = google_project_iam_custom_role.gcp_bq_factory.id
  member  = "serviceAccount:${google_service_account.automation_sa.email}"
}
