# Copyright (c) 2025 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

locals {
  # These values can be used in an override file.
  tag_namespace_name           = ""
  all_tags_defined_tags        = {}
  all_tags_freeform_tags       = {}

  tags_configuration = {
    default_compartment_id = var.tenancy_ocid
    cis_namespace_name     = length(local.tag_namespace_name) > 0 ? local.tag_namespace_name : local.default_tag_namespace_name
    default_defined_tags   = local.tags_defined_tags,
    default_freeform_tags  = local.tags_freeform_tags

    namespaces = {
      ARCH-CENTER-NAMESPACE = {
        name        = "ArchitectureCenter\\wl-ai-tm-${var.workload_name}"
        description = "AI Transaction Monitoring tag namespace for OCI Architecture Center."
        is_retired  = false
        tags = {
          ARCH-CENTER-TAG = {
            name        = "release"
            description = "AI Transaction Monitoring tag for OCI Architecture Center."
          }
        }
      }
    }
  }

  ##### DON'T TOUCH ANYTHING BELOW #####
  default_tags_defined_tags  = null
  default_tags_freeform_tags = null

  tags_defined_tags  = length(local.all_tags_defined_tags) > 0 ? local.all_tags_defined_tags : local.default_tags_defined_tags
  tags_freeform_tags = length(local.all_tags_freeform_tags) > 0 ? merge(local.all_tags_freeform_tags, local.default_tags_freeform_tags) : local.default_tags_freeform_tags

  default_tag_namespace_name = "${var.workload_name}-namesp"
}

module "workload_tags" {
  source             = "github.com/oci-landing-zones/terraform-oci-modules-governance//tags?ref=v0.1.5"
  tags_configuration = local.tags_configuration
  tenancy_ocid       = var.tenancy_ocid
}
