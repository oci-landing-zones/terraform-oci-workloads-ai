# AI Transaction Monitoring Workload Template

This template shows how to deploy an AI Transaction Monitoring Workload configuration with no public load balancer and backend set. 

In this template, a single GPU-based compute instance and block volume are deployed, with NVFlare's Graph Neural Network (GNN) to apply federated learning to a GNN model, specifically using GraphSAGE for tasks like transactional fraud detection.
The following prerequisite resources are assumed to exist prior to deploying this workload:

- a workload compartment for holding the compute instance and block volume
- an application compartment with a private application subnet with a VCN, including a DRG and NAT gateway for outbound access to the internet.
- optionally, a public web subnet for holding a load balancer used in a mesh network environment.

For new environments, we recommend deploying the [OCI Core Landing Zone](https://github.com/oci-landing-zones/terraform-oci-core-landingzone) with a Three-Tiered VCN and an App Subnet connected to a NAT Gateway to provide a well-architected prescriptive onboarding experience that is secured with the CIS OCI Benchmark.

## Default Values

This template has the following parameters set:

| Variable Name | Description | Value | Options |
|---|---|---|---|
| workload\_name | Name of the workload. Default name is TMS. | TMS | |
| workload\_compartment\_ocid | OCID of the existing Workload Compartment. | | |
| app\_subnet\_compartment\_ocid | OCID of the existing Network Compartment. | | |
| app\_subnet\_ocid | OCID of the existing App Subnet. | | |
| app\_nsg\_ocid | OCID of the existing App NSG. | | |
| add\_lb | Whether to deploy a load balancer. If set to true, a load balancer will be deployed and the compute instance will be attached to the backend server. If set to false, the load balancer and backend set will not be created. | false | |
| lb\_subnet\_compartment\_ocid | OCID of the Load Balancer compartment. | | |
| lb\_subnet\_ocid | OCID of the existing LB Subnet. | | |
| compute\_shape | GPU-based shape of the compute instance. | VM.GPU.A10.1 | |
| compute\_boot\_volume\_size | Boot volume size (in GBs) of the compute instance. | 250 | |
| compute\_ssh\_public\_key | Public SSH Key used to access the compute instance. | | |
| compute\_availability\_domain | Availability domain where the compute instance will be deployed. Default is AD-1. | 1 | |
| compute\_fault\_domain | Fault domain where the compute instance will be deployed. Default is FD-1. | 1 | |
| block\_volume\_size | Block volume size (in GBs) to be attached to the compute instance. | 200 | |

For a detailed description of all variables that can be used, see the [Spec](../../SPEC.md) documentation.

This template can be deployed using OCI Resource Manager Service (RMS) or Terraform CLI:

## OCI RMS Deployment

By clicking the button below, you are redirected to an OCI RMS Stack with variables pre-assigned for deployment.

[![Deploy_To_OCI](../../../images/DeployToOCI.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oci-landing-zones/terraform-oci-workloads-ai//ai_transaction_monitoring_workload/archive/refs/heads/main.zip&zipUrlVariables={"workload_name":"TMS","workload_compartment_ocid":"","app_subnet_compartment_ocid":"","app_subnet_ocid":"","app_nsg_ocid":"","add_lb":false,"lb_subnet_compartment_ocid":"","lb_subnet_ocid":"","compute_shape":"VM.GPU.A10.1","compute_boot_volume_size":"250","compute_ssh_public_key":"","compute_availability_domain":"1","compute_fault_domain":"1","block_volume_size":"200"})

You are required to review/adjust the following variable settings:

- Provide existing OCIDs for *workload\_compartment\_ocid*, *app\_subnet\_compartment\_ocid*, *app\_subnet\_ocid*, *app\_nsg\_ocid* and if opted for, *lb\_subnet\_compartment\_ocid* and *lb\_subnet\_\_ocid* fields if *add\_lb* is set to *true*.
- Check *add\_lb* option in case it is desired.
- Make sure to enter the *compute\_ssh\_public\_key* variable with a public SSH key for the compute instance.
- Be sure to adjust *compute\_availability\_domain* and *compute\_fault\_domain* to match your GPU shape availability.

With the stack created, perform a Plan, followed by an Apply using RMS UI.

## Terraform CLI Deployment

1. Rename file *main.tf.template* to *main.tf*.
2. Provide/review the variable assignments in *main.tf*.
3. In this folder, execute the typical Terraform workflow:

	``
	terraform init
	``
	
	``
	terraform plan
	``
	
	``
	terraform apply
	``






