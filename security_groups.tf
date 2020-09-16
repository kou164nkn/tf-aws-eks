/*
# == To ControlPlane From DataPlane ============================
resource "aws_security_group" "to_control-from_data" {
  name        = "ControlPlaneSecurityGroup"
  description = "Communication between the control plane and worker nodegroups"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow control plane to receive API requests from worker nodes"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "control-plane-security-group"
  }
}

resource "aws_security_group_rule" "tcfd-egress-other" {
  description              = "Allow control plane to communicate with worker node (kubelet and workload TCP ports)"
  type                     = "egress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.to_data-from_control.id
  security_group_id        = aws_security_group.to_control-from_data.id
}

resource "aws_security_group_rule" "tcfd-egress-https" {
  description              = "Allow control plane to communicate with worker nodes (workloads using HTTPS port, commonly used with extension API servers)"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.to_data-from_control.id
  security_group_id        = aws_security_group.to_control-from_data.id
}
# =========================================================


# == To DataPlane From ControlPlane =======================
resource "aws_security_group" "to_data-from_control" {
  name        = "NodeGroupSecurityGroup"
  description = "Communication between the control plane and worker nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow worker nodes to communicate with control plane (kubelet and workload TCP ports)"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.to_control-from_data.id]
  }

  ingress {
    description     = "Allow worker nodes to communicate with control plane (workloads using HTTPS port, commonly used with extension API servers)"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.to_control-from_data.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "node-group-security-group"
  }
}
# =========================================================


# == each worker node =====================================
resource "aws_security_group" "node" {
  name        = "ClusterSharedNodeSecurityGroup"
  description = "Communication between all nodes in the cluster"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ingress" {
  description              = "Allow managed and unmanaged nodes to communicate with each other (all ports)"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.managed.id
  security_group_id        = aws_security_group.node.id
}

resource "aws_security_group_rule" "ingress-hoge" {
  description              = "Allow nodes to communicate with each other (all ports)"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.node.id
  security_group_id        = aws_security_group.node.id
}
# =========================================================


resource "aws_security_group" "managed" {
  description = "EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow unmanaged nodes to communicate with control plane (all ports)"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.node.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ingress-fuga" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.managed.id
  security_group_id        = aws_security_group.managed.id
}
# =========================================================
*/