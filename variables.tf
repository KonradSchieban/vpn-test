variable "project_id" {
  description = "The GCP project ID to deploy the resources in."
  type        = string
}

variable "vpc_a_name" {
  description = "Name for VPC A."
  type        = string
  default     = "vpc-a"
}

variable "vpc_b_name" {
  description = "Name for VPC B."
  type        = string
  default     = "vpc-b"
}

variable "vpc_a_subnet_cidr" {
  description = "CIDR range for the subnet in VPC A."
  type        = string
  default     = "10.0.0.0/24"
}

variable "vpc_b_subnet_cidr" {
  description = "CIDR range for the subnet in VPC B."
  type        = string
  default     = "10.1.0.0/24"
}

variable "region" {
  description = "The GCP region to deploy the resources in."
  type        = string
  default     = "europe-west3"
}
