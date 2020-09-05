# == IAM ==================================================
resource "aws_iam_role" "eks_cluster" {
  name = "eks-deploy_eks-cluster"
assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "aws_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "aws_eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}
# =========================================================


# == Cluster ==============================================
resource "aws_eks_cluster" "main" {
  name     = "eks-deploy_cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id]
    subnet_ids         = aws_subnet.public-subnet[*].id
  }
# Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
# Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_cluster_policy,
    aws_iam_role_policy_attachment.aws_eks_service_policy
  ]
}
# =========================================================


# == ClusterSecurityGroup =================================
resource "aws_security_group" "eks_cluster" {
  name        = "eks-deploy"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.main.id
tags = {
    Name = "control-plane_security-group"
  }
}

resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  type                     = "egress"
  from_port                = 1024
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
}
# =========================================================


# == NodeSecurityGroup ====================================
resource "aws_security_group" "eks_nodes" {
  name        = "data-plane-security-group"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.main.id
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
    Name                                       = "data-plane-security-group"
    "kubernetes.io/cluster/eks-deploy_cluster" = "owned"
  }
}

resource "aws_security_group_rule" "nodes" {
  description              = "Allow nodes to communicate with each other"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "nodes_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
}
# =========================================================