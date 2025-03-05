# Copyright (c) 2025 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  l7_load_balancers_configuration = {
    l7_load_balancers = {
      WORKLOAD-LB = {
        network_configuration_category = null
        compartment_id                 = var.workload_compartment_ocid
        display_name                   = "${var.workload_name}-loadbalancer"
        shape                          = "flexible"
        shape_details = {
          maximum_bandwidth_in_mbps = 100,
          minimum_bandwidth_in_mbps = 10
        }
        subnet_keys      = null
        subnet_ids       = [var.lb_subnet_ocid]
        is_private       = false
        reserved_ips_ids = []
        backend_sets = {
          WK-LB-BACKEND-SET-1 = {
            health_checker = {
              protocol            = "HTTP",
              interval_ms         = 10000,
              is_force_plain_text = true,
              port                = 8888,
              retries             = 3,
              return_code         = 200,
              timeout_in_millis   = 3000,
              url_path            = "/"
            }
            name   = "${var.workload_name}-backend-set-1"
            policy = var.lb_policy
            backends = {
              BACKEND-1 = {
                ip_address = module.workload_compute.instances["WORKLOAD-INSTANCE"].private_ip
                port       = 8888
              }
            }
          }
        }
      }
    }
    dependencies = {
      network_security_groups = null
      subnets                 = null
      network_security_groups = null
    }
  }
}

module "workload_lb" {
  count                           = var.add_lb ? 1 : 0
  source                          = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking.git?ref=v0.7.3/modules/l7_load_balancers"
  l7_load_balancers_configuration = local.l7_load_balancers_configuration
}