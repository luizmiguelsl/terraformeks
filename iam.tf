resource "aws_iam_user" "bitbucketpipelines" {
  name = "${local.project}-${var.env}-bitbucketpipelines"
}
resource "aws_iam_access_key" "bitbucketpipelines" {
  user = aws_iam_user.bitbucketpipelines.name
}

# Dividimos em duas action pois a GetAuthorizationToken precisa esta liberado em todos os recursos.
#Obs: o RH interfere diretamente nos seguintes projetos: api-rh-digital e pwa-rh-digital.
resource "aws_iam_user_policy" "bitbucketpipelines" {
  name = "${local.project}-${var.env}-bitbucketpipelines"
  user = aws_iam_user.bitbucketpipelines.name

  #Separamos todos os blocos de action por recursos.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${local.project}-${var.env}-bitbucketpipelines"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
        ]
        Effect = "Allow"
        "Resource" : "*"
      },
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeTags"
        ]
        Resource : "arn:aws:ec2:::*"
      }
    ]
  })
}

output "iam_pipeline_user" {
  value = aws_iam_user.bitbucketpipelines.name
}
output "iam_pipeline_access_key" {
  value = aws_iam_access_key.bitbucketpipelines.id
}
output "iam_pipeline_access_secret" {
  value = aws_iam_access_key.bitbucketpipelines.secret
}