# modules/vpc/variables.tf

variable "environment" {
  description = "Name prefix for resources"
  type        = string
}

variable "prefix" {
  type        = string
  description = "(Required) Prefix to use for all resources in this module."
  default     = "roadpass"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "172.16.0.0/16"
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "az_count" {
  description = "Number of availability zones"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}