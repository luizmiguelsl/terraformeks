data "aws_availability_zones" "available" {
  state = "available"
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0.0"

  name = "${local.project}-${var.env}"

  cidr = var.cidr

  azs = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2],
  ]
  public_subnets  = [cidrsubnet(var.cidr, 2, 0), cidrsubnet(var.cidr, 2, 1)]
  private_subnets = [cidrsubnet(var.cidr, 2, 2), cidrsubnet(var.cidr, 2, 3)]

  public_subnet_tags = {
    Private                                             = false
    "kubernetes.io/role/internal-elb"                   = 1
    "kubernetes.io/role/elb"                            = 1
    "kubernetes.io/cluster/${var.env}-${local.project}" = "shared"
  }

  private_subnet_tags = {
    Private                                             = true
    "kubernetes.io/role/internal-elb"                   = 1
    "kubernetes.io/cluster/${var.env}-${local.project}" = "shared"
  }

  create_database_subnet_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_vpn_gateway = false

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 600

  tags = {
    Owner       = local.owner
    Project     = local.board
    Environment = var.env
  }

}

data "aws_subnet_ids" "eks" {
  vpc_id = module.vpc.vpc_id
}

output "all_subnets_id" {
  value = data.aws_subnet_ids.eks.ids
}