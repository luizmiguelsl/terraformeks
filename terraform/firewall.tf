resource "aws_security_group" "StandardRulesToAllResources" {
  name        = "StandardRulesToAllResources"
  description = "Default rules to all resources whitin the VPC"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.world_cidr]
    description = "Allow Outbound to any destination"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    self        = true
    description = "Allow ICMP from the SG itself"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self        = true
    description = "Allow SSH connection from the SG itself"
  }

  tags = {
    Project = local.board
  }
}