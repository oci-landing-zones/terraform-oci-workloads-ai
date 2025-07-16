## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |

## Modules

| Name | Source | Version                          |
|------|--------|----------------------------------|
| <a name="module_workload_compute"></a> [workload\_compute](#module\_workload\_compute) | github.com/oci-landing-zones/terraform-oci-modules-workloads//cis-compute-storage | v0.2.1                           |
| <a name="module_workload_lb"></a> [workload\_lb](#module\_workload\_lb) | github.com/oci-landing-zones/terraform-oci-cis-landing-zone-networking.git | v0.7.5/modules/l7_load_balancers |
| <a name="module_workload_tags"></a> [workload\_tags](#module\_workload\_tags) | github.com/oci-landing-zones/terraform-oci-modules-governance//tags | v0.1.5                           |

## Resources

| Name | Type |
|------|------|
| [oci_core_images.gpu_images](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_images) | data source |
| [oci_core_subnet.lb_subnet](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_lb"></a> [add\_lb](#input\_add\_lb) | Whether to deploy a load balancer. If set to true, a load balancer will be deployed and the compute instance will be attached to the backend server. If set to false, the load balancer and backend set will not be created. | `bool` | `false` | no |
| <a name="input_app_nsg_ocid"></a> [app\_nsg\_ocid](#input\_app\_nsg\_ocid) | OCID of the existing Network Security Group (NSG). Required security rules should be set up prior to workload deployment. | `string` | `null` | no |
| <a name="input_app_subnet_ocid"></a> [app\_subnet\_ocid](#input\_app\_subnet\_ocid) | OCID of the existing App Subnet. | `string` | `null` | no |
| <a name="input_block_volume_size"></a> [block\_volume\_size](#input\_block\_volume\_size) | Block volume size (in GBs) to be attached to the compute instance. | `number` | `200` | no |
| <a name="input_cis_level"></a> [cis\_level](#input\_cis\_level) | Determines CIS OCI Benchmark Level to apply on workload managed resources. Level 1 is be practical and prudent. Level 2 is intended for environments where security is more critical than manageability and usability. Level 2 drives the creation of block volume encryption with a customer managed key. | `string` | `"1"` | no |
| <a name="input_compute_availability_domain"></a> [compute\_availability\_domain](#input\_compute\_availability\_domain) | Availability domain where the compute instance will be deployed. Default is AD-1. | `number` | `1` | no |
| <a name="input_compute_boot_volume_size"></a> [compute\_boot\_volume\_size](#input\_compute\_boot\_volume\_size) | Boot volume size (in GBs) of the compute instance. | `number` | `250` | no |
| <a name="input_compute_fault_domain"></a> [compute\_fault\_domain](#input\_compute\_fault\_domain) | Fault domain where the compute instance will be deployed. Default is FD-1. | `number` | `1` | no |
| <a name="input_compute_shape"></a> [compute\_shape](#input\_compute\_shape) | GPU-based shape of the compute instance. | `string` | `"VM.GPU.A10.1"` | no |
| <a name="input_compute_ssh_public_key"></a> [compute\_ssh\_public\_key](#input\_compute\_ssh\_public\_key) | Public SSH Key used to access the compute instance. | `string` | `null` | no |
| <a name="input_fingerprint"></a> [fingerprint](#input\_fingerprint) | n/a | `string` | `""` | no |
| <a name="input_lb_policy"></a> [lb\_policy](#input\_lb\_policy) | The load balancing policy for distributing incoming traffic to backend servers. | `string` | `"ROUND_ROBIN"` | no |
| <a name="input_lb_subnet_ocid"></a> [lb\_subnet\_ocid](#input\_lb\_subnet\_ocid) | OCID of the Load Balancer Subnet. | `string` | `""` | no |
| <a name="input_private_key_password"></a> [private\_key\_password](#input\_private\_key\_password) | Private key password | `string` | `""` | no |
| <a name="input_private_key_path"></a> [private\_key\_path](#input\_private\_key\_path) | Private key path | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where resources are deployed. | `string` | n/a | yes |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | Tenancy OCID | `string` | `""` | no |
| <a name="input_user_ocid"></a> [user\_ocid](#input\_user\_ocid) | User OCID | `string` | `""` | no |
| <a name="input_workload_compartment_ocid"></a> [workload\_compartment\_ocid](#input\_workload\_compartment\_ocid) | OCID of the existing Workload Compartment. | `string` | `null` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Name of the workload. Default name is TMS | `string` | `"TMS"` | no |

## Outputs

No outputs.
