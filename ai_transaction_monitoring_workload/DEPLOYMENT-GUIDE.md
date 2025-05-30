# AI Transaction Monitoring Workload Deployment Guide

This template shows how to deploy an AI Transaction Monitoring Workload using an OCI Core Landing Zone configuration.

In this template, a single GPU-based compute instance is deployed, optionally with a dedicated application load balancer and backend set.
The following prerequisite resources are assumed to exist prior to deploying this workload:

- a workload compartment for holding the compute instance and block volume
- an application compartment with a private application subnet with a VCN, including a DRG and NAT gateway for outbound access to the internet.
- optionally, a public web subnet for holding a load balancer used in a mesh network environment.

Because this module deploys a Graphical Processing Unit (GPU) based compute instance, the first task is to enable that capacity in your tenancy.  See the *Deploy* section of the companion [README](README.md) file for instructions on increasing GPU Service Limits before attempting to deploy.

## Architectural Overlay

Before you can deploy this module, there must be existing tenancy resources (compartments, VCNs, subnets, etc.) that provide a foundation for the workload or application. The information here assumes you will use [Core Landing Zone](https://github.com/oci-landing-zones/terraform-oci-core-landingzone) for the base deployment. Alternatively, you may choose to use [Operating Entities Landing Zone](https://github.com/oci-landing-zones/oci-landing-zone-operating-entities) depending on your organization and workload size or complexity.

The diagram below shows the AI Transaction Monitoring Workload deployed resources as indicated with a yellow background.  All other resources are deployed as a prerequisite by Core Landing Zone with the following user supplied options:

- Networking topology: Hub and Spoke model (Hub/DMZ VCN with a DRG), which includes subnets and NSGs for web, indoor firewall and jump host uses.  This option also provides a NAT gateway, which is needed for externally available code installed on the compute instance. Those destination URLs are:
  - https://download.docker.com/linux/centos/docker-ce.repo
  - https://github.com/NVIDIA/NVFlare.git
  - https://data.pyg.org/whl/torch-2.4.0+cpu.html
  - https://objectstorage.us-ashburn-1.oraclecloud.com/n/ocisateam/b/EllipticPlusPlusDataset/o/TransactionsDataset.zip
  - https://github.com/adinadiana1234/transactionmonitoring_notebooks.git
- OCI Firewall in the Hub/DMZ VCN, required for proper routing within the landing zone.
- Bastion jump host, with Oracle Linux 8 STIG image, in the Hub/DMZ VCN, required for SSH access to the compute instance on a private subnet.
- A single Three Tier VCN (spoke) attached to the DRG, which includes an application subnet and its associated NSG.

A separate application compartment is deployed automatically by Core Landing Zone.  OCID values from these prerequisite resources are used as input to this module for placement of the compute instance, associated block storage and application load balancer, if included.
 
![AI-TMS-arch](../images/AI-TMS-arch.png)

The decision on whether or not to use a public load balancer is based on the complexity of your network. Normally, a load balancer is only used for local scaling and to allow internet traffic. With a Hub and Spoke topology, the load balancer facilitates routing to the application in the spoke VCN.

## Default Values

This template has the following parameters set:

| Variable Name | Description | Value | Options |
|---|---|---|---|
| workload\_name | Name of the workload. Default name is TMS. | TMS | Any string |
| workload\_compartment\_ocid | OCID of the existing Workload Compartment. | null | User input |
| app\_subnet\_compartment\_ocid | OCID of the existing Network Compartment. | null | User input |
| app\_subnet\_ocid | OCID of the existing App Subnet. | null | User input |
| app\_nsg\_ocid | OCID of the existing App NSG. | null | User input |
| add\_lb | Whether to deploy a load balancer. If set to true, a load balancer will be deployed and the compute instance will be attached to the backend server. If set to false, the load balancer and backend set will not be created. | false | true, false |
| lb\_subnet\_compartment\_ocid | OCID of the Load Balancer compartment. | null | User input |
| lb\_subnet\_ocid | OCID of the existing LB Subnet. | null | User input |
| compute\_shape | GPU-based shape of the compute instance. | VM.GPU.A10.1 | VM.GPU.A10.1, VM.GPU.A10.2, BM.GPU.A10.4, VM.GPU2.1, BM.GPU2.2, VM.GPU3.1, VM.GPU3.2, VM.GPU3.4, BM.GPU3.8, |
| compute\_boot\_volume\_size | Boot volume size (in GBs) of the compute instance. | 250 | > 250 GB |
| compute\_ssh\_public\_key | Public SSH Key used to access the compute instance. | null | User input |
| compute\_availability\_domain | Availability domain where the compute instance will be deployed. Default is AD-1. | 1 | tenancy AD count (1 or 3) |
| compute\_fault\_domain | Fault domain where the compute instance will be deployed. Default is FD-1. | 1 | tenancy FD count (2) |
| block\_volume\_size | Block volume size (in GBs) to be attached to the compute instance. | 200 | > 200 GB |

For a detailed description of all variables that can be used, see the [SPEC.md](SPEC.md) documentation.

This template can be deployed using OCI Resource Manager Service (RMS) or Terraform CLI:

## OCI RMS Deployment

By clicking the button below, you are redirected to an OCI RMS Stack with variables pre-assigned for deployment.

[![Deploy_To_OCI](../images/DeployToOCI.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oci-landing-zones/terraform-oci-workloads-ai/archive/refs/heads/main.zip&zipUrlVariables={"workload_name":"TMS","workload_compartment_ocid":"","app_subnet_compartment_ocid":"","app_subnet_ocid":"","app_nsg_ocid":"","add_lb":false,"lb_subnet_compartment_ocid":"","lb_subnet_ocid":"","compute_shape":"VM.GPU.A10.1","compute_boot_volume_size":"250","compute_ssh_public_key":"","compute_availability_domain":"1","compute_fault_domain":"1","block_volume_size":"200"})

You are required to review/adjust the following variable settings:

- Provide existing OCIDs for *workload\_compartment\_ocid*, *app\_subnet\_compartment\_ocid*, *app\_subnet\_ocid*, and if opted for, *lb\_subnet\_compartment\_ocid* and *lb\_subnet\_\_ocid* fields.
- Check *add\_lb* option in case it is desired.
- Make sure to enter the *compute\_ssh\_public\_key* variable with a public SSH key for the compute instance.
- Be sure to adjust *compute\_availability\_domain* and *compute\_fault\_domain* to match your GPU shape availability.

**NOTE:** Terraform Apply will fail if the GPU capacity is not in the indicated Fault Domain.  The Fault Domain value is required, but there is no way to verify that value beforehand in the OCI console.  You may have to retry the Apply after incrementing the Fault Domain value.

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

