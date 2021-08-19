variable "env" {
  type = string
}

variable "cidr" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "k8s_service_account_namespace" {
  type = string
}

variable "k8s_service_account_name" {
  type = string
}

variable "world_cidr" {
  type    = string
  default = "0.0.0.0/0"
}