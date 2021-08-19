resource "aws_iam_user" "pipelines" {
  name = "${local.project}-${var.env}-pipelines"
}
resource "aws_iam_access_key" "pipelines" {
  user = aws_iam_user.pipelines.name
}

# Dividimos em duas action pois a GetAuthorizationToken precisa esta liberado em todos os recursos.
resource "aws_iam_user_policy" "pipelines" {
  name = "${local.project}-${var.env}-pipelines"
  user = aws_iam_user.pipelines.name

  #Separamos todos os blocos de action por recursos.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${local.project}-${var.env}-pipelines"
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
  value = aws_iam_user.pipelines.name
}
output "iam_pipeline_access_key" {
  value = aws_iam_access_key.pipelines.id
}
output "iam_pipeline_access_secret" {
  value = aws_iam_access_key.pipelines.secret
}