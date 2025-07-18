# Copyright (c) 2025 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_core_images" "gpu_images" {
  compartment_id           = var.workload_compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.compute_shape
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"

  filter {
    name   = "launch_mode"
    values = ["NATIVE"]
  }
  filter {
    name   = "display_name"
    values = ["\\w*GPU\\w*"]
    regex  = true
  }
}

locals {
  instances_configuration = {
    default_compartment_id      = var.workload_compartment_ocid
    default_subnet_id           = var.app_subnet_ocid
    default_ssh_public_key_path = var.compute_ssh_public_key
    instances = {
      WORKLOAD-INSTANCE = {
        shape                         = var.compute_shape
        name                          = "${var.workload_name}-instance"
        disable_legacy_imds_endpoints = var.cis_level == "2" ? true : var.compute_disable_legacy_imds_endpoints
        placement = {
          availability_domain = var.compute_availability_domain
          fault_domain        = var.compute_fault_domain
        }
        boot_volume = {
          size                          = var.compute_boot_volume_size
          preserve_on_instance_deletion = false
        }
        networking = {
          hostname                = substr(replace(lower(var.workload_name), "-_", ""), 0, 14)
          assign_public_ip        = false
          network_security_groups = [var.app_nsg_ocid]
        }
        platform_image = {
          ocid = data.oci_core_images.gpu_images.images[0].id
        }
        cloud_agent = {
          disable_monitoring = false
          disable_management = false
          plugins = [
            { name = "Custom Logs Monitoring", enabled = true },
            { name = "Compute Instance Run Command", enabled = true },
            { name = "Compute Instance Monitoring", enabled = true }
          ]
        }
        cloud_init = {
          script_file = "./cloudinit.sh"
        }
        encryption = {
          encrypt_in_transit_on_instance_create = true
          kms_key_id                            = var.cis_level == "2" ? var.customer_key_ocid : null
        }
      }
    }
  }
  storage_configuration = {
    default_compartment_id = var.workload_compartment_ocid
    block_volumes = {
      BLOCK-VOLUME = {
        display_name        = "${var.workload_name}-block-volume"
        volume_size         = var.block_volume_size
        availability_domain = var.compute_availability_domain
        attach_to_instances = [{
          device_name     = null
          instance_id     = "WORKLOAD-INSTANCE"
          attachment_type = "paravirtualized"
        }]
        encryption = {
          encrypt_in_transit = true
          kms_key_id         = var.cis_level == "2" ? var.customer_key_ocid : null
        }
      }
    }
  }
}

module "workload_compute" {
  source = "github.com/oci-landing-zones/terraform-oci-modules-workloads//cis-compute-storage?ref=v0.2.1"
  providers = {
    oci                                  = oci
    oci.block_volumes_replication_region = oci
  }
  instances_configuration = local.instances_configuration
  tenancy_ocid            = var.tenancy_ocid
  storage_configuration   = local.storage_configuration
}
