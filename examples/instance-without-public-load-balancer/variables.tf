# Copyright (c) 2025 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# ------------------------------------------------------
# ----- General
#-------------------------------------------------------
variable "tenancy_ocid" {
  default = ""
}
variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}
variable "private_key_password" {
  default = ""
}
variable "region" {
  description = "The region where resources are deployed."
  type        = string
}

# ------------------------------------------------------
# ----- Workload
#-------------------------------------------------------
variable "workload_name" {
  description = "Name of the workload. Default name is TMS"
  validation {
    condition     = length(regexall("^[A-Za-z][A-Za-z0-9]", var.workload_name)) > 0
    error_message = "Validation failed for workload_name: value must contain alphanumeric characters only, starting with a letter."
  }
  default = "TMS"
}

variable "workload_compartment_ocid" {
  description = "OCID of the existing Workload Compartment."
  type        = string
  default     = null
}

variable "app_subnet_ocid" {
  description = "OCID of the existing App Subnet."
  type        = string
  default     = null
}

variable "app_nsg_ocid" {
  description = "OCID of the existing Network Security Group (NSG). Required security rules should be set up prior to workload deployment."
  type        = string
  default     = null
}

# ------------------------------------------------------
# ----- Compute Instance
#-------------------------------------------------------

variable "compute_shape" {
  description = "GPU-based shape of the compute instance."
  type        = string
  default     = "VM.GPU.A10.1"
}

variable "compute_boot_volume_size" {
  description = "Boot volume size (in GBs) of the compute instance."
  type        = number
  default     = 250
}

variable "compute_ssh_public_key" {
  description = "Public SSH Key used to access the compute instance."
  type        = string
  default     = null
}

variable "compute_availability_domain" {
  description = "Availability domain where the compute instance will be deployed. Default is AD-1."
  type        = number
  default     = 1
}

variable "compute_fault_domain" {
  description = "Fault domain where the compute instance will be deployed. Default is FD-1."
  type        = number
  default     = 1
}

# ------------------------------------------------------
# ----- Block Volume
#-------------------------------------------------------

variable "block_volume_size" {
  description = "Block volume size (in GBs) to be attached to the compute instance."
  type        = number
  default     = 200
}

# ------------------------------------------------------
# ----- Load Balancer
#-------------------------------------------------------
variable "add_lb" {
  description = "Whether to deploy a load balancer. If set to true, a load balancer will be deployed and the compute instance will be attached to the backend server. If set to false, the load balancer and backend set will not be created."
  type        = bool
  default     = false
}

variable "lb_subnet_ocid" {
  description = "OCID of the Load Balancer Subnet."
  type        = string
  default     = ""
}

variable "lb_policy" {
  description = "The load balancing policy for distributing incoming traffic to backend servers."
  type        = string
  default     = "ROUND_ROBIN"
}
