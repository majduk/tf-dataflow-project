/**
 * Copyright 2023 Google. This software is provided as-is,
 * without warranty or representation for any use or purpose.
 * Your use of it is subject to your agreement with Google.
 */

resource "google_folder" "parent" {
  display_name = var.parent_folder_name
  parent       = "organizations/${var.org_id}"
}


