# Terraform Dataflow Project

Simple use of the [Cloud Foundations Fabric](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric) project factory module.

Creates the project, VPC and subnet needed to create dataflow resources.

Usage:
```
./generate_provider.py
terraform init
terraform apply
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.43.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.43.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.8.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_data_project"></a> [data\_project](#module\_data\_project) | terraform-google-modules/project-factory/google | ~> 14.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | ~> 7.0 |

## Resources

| Name | Type |
|------|------|
| [google_folder.parent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder) | resource |
| [google_project_iam_custom_role.gcp_bq_factory](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_custom_role.gcp_bt_factory](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.automation_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.automation_sa_bqf](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.automation_sa_btf](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.dataflow_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.automation_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.dataflow_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket.tfstate_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket.tmp_dir_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [local_file.tfvars](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_id.random_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | The ID of the billing account to associate projects with. | `string` | n/a | yes |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | GCP Organization ID | `string` | n/a | yes |
| <a name="input_outputs_location"></a> [outputs\_location](#input\_outputs\_location) | Outputs location | `string` | n/a | yes |
| <a name="input_parent_folder_name"></a> [parent\_folder\_name](#input\_parent\_folder\_name) | Organization's parent folder name | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project to create | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Project region | `string` | n/a | yes |
| <a name="input_terraform_sa"></a> [terraform\_sa](#input\_terraform\_sa) | Service account used by terraform | `string` | n/a | yes |
| <a name="input_tfstate_bucket_name"></a> [tfstate\_bucket\_name](#input\_tfstate\_bucket\_name) | Bucket for storing terraform state | `string` | n/a | yes |

## Outputs

No outputs.
