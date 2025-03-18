# Copyright (c) 2025 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  instances_configuration = {
    default_compartment_id      = var.workload_compartment_ocid
    default_subnet_id           = var.app_subnet_ocid
    default_ssh_public_key_path = var.compute_ssh_public_key
    instances                   = {
      WORKLOAD-INSTANCE = {
        shape     = var.compute_shape
        name      = "${var.workload_name}-instance"
        placement = {
          availability_domain = var.compute_availability_domain
          fault_domain        = var.compute_fault_domain
        }
        boot_volume = {
          size                          = var.compute_boot_volume_size
          preserve_on_instance_deletion = false
          type                          = "iscsi"
        }
        volumes_emulation_type = "iscsi"
        networking = {
          hostname                = "${var.workload_name}-instance"
          assign_public_ip        = false
          type                    = "vfio"
        }
        marketplace_image = {
          name = "AI 'all-in-one' Data Science Image for GPU"
        }
        cloud_agent = {
          disable_monitoring = false
          disable_management = false
          plugins = [
            {name = "Custom Logs Monitoring", enabled = true},
            {name = "Compute Instance Run Command", enabled = true},
            {name = "Compute Instance Monitoring", enabled = true}
          ]
        }
      }
    }
  }
  storage_configuration = {
    default_compartment_id = var.workload_compartment_ocid
    block_volumes = {
      BLOCK-VOLUME = {
        display_name = "${var.workload_name}-block-volume"
        volume_size = var.block_volume_size
        availability_domain = var.compute_availability_domain
        attach_to_instances = [{
          device_name = null
          instance_id = "WORKLOAD-INSTANCE"
          attachment_type = "iscsi"
      }]
      }
    }
  }
}

module "workload_compute" {
  source = "github.com/oracle-quickstart/terraform-oci-secure-workloads//cis-compute-storage?ref=v0.1.9"
  providers = {
    oci = oci
    oci.block_volumes_replication_region = oci
  }
  instances_configuration = local.instances_configuration
  tenancy_ocid = var.tenancy_ocid
  storage_configuration = local.storage_configuration
}
