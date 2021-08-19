terraform {
  required_version = ">= 0.14.3"
  backend "remote" {
    organization = "TechLabsLM"

    workspaces {
      prefix = "igti-eks-"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.1.2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.1.0"
    }
  }
}

locals {
  customer = "igti"
  project  = "eks"
  provider = "aws"
  region   = "spo"
  board    = "IGTI"
  owner    = "Luiz Miguel"
}

#Comando para gerar o kubeconfig aws --region sa-east-1 eks update-kubeconfig --kubeconfig kubeconfig_homolog.yaml --name homolog-rh
provider "helm" {
  kubernetes {
    config_path = "${path.module}/kubeconfig_${var.env}-${local.project}"
  }
}