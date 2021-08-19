data "aws_eks_cluster" "cluster" {
  name = module.transformacao-digital.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.transformacao-digital.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "transformacao-digital" {
  source                        = "terraform-aws-modules/eks/aws"
  cluster_name                  = "${var.env}-${local.project}"
  cluster_version               = "1.19"
  subnets                       = data.aws_subnet_ids.eks.ids
  vpc_id                        = module.vpc.vpc_id
  enable_irsa                   = true
  cluster_create_security_group = true
  cluster_security_group_id     = aws_security_group.StandardRulesToAllResources.id
  version                       = "15.2.0"

  map_users = [
    {
      userarn  = aws_iam_user.pipelines.arn
      username = aws_iam_user.pipelines.name
      groups   = ["system:masters"]
    },
  ]
  node_groups_defaults = {
    ami_type                  = "AL2_x86_64"
    disk_size                 = 60
    source_security_group_ids = [aws_security_group.StandardRulesToAllResources.id]
    k8s_labels = {
      Environment = var.env
    }

    additional_tags = {
      Owner                                                                  = local.owner
      Project                                                                = local.board
      Environment                                                            = var.env
      Type                                                                   = "node"
      "k8s.io/cluster-autoscaler/enabled"                                    = true
      "k8s.io/cluster-autoscaler/${module.transformacao-digital.cluster_id}" = true
    }

  }

  node_groups = {
    "node" = {
      key_name         = "igti-btc-aws"
      desired_capacity = 2
      max_capacity     = 5
      min_capacity     = 2
      instance_types   = [var.instance_type]

    }
  }

  tags = {
    Owner       = local.owner
    Project     = local.board
    Environment = var.env
  }
}
resource "null_resource" "tag" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = templatefile("scripts/tags.sh.tpl", {
      owner       = local.owner
      project     = local.board
      environment = var.env
      resource_id = join(", ", module.transformacao-digital.node_groups.node.resources.*.autoscaling_groups.0.name)
      name        = "${local.project}-${var.env}-eks-node-pool"
      region      = var.region
    })
  }
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "eks_cluster_arn" {
  value = data.aws_eks_cluster.cluster.arn
}