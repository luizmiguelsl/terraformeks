variable "redis_engine_version" {
  type    = string
  default = "3.2.6"
}
variable "redis_family" {
  type    = string
  default = "redis3.2"
}
variable "repositories" {
  type    = list(string)
  default = ["backend-rh", "backoffice-rh", "colaboradores-rh"]
}

variable "region" {
  type    = string
  default = "sa-east-1"
}