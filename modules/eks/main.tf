# Create EKS cluster
resource "aws_eks_cluster" "eks" {
  name                        = var.eks_common.name
  role_arn                    = var.cluster_role.arn

  enabled_cluster_log_types   = ["api", "audit"]

  vpc_config {
    subnet_ids = var.subnets
  }
}


# Create EKS nodegroup
resource "aws_eks_node_group" "nodegroup" {
  cluster_name                = aws_eks_cluster.eks.name
  node_group_name             = var.eks_common.nodegroup.name
  node_role_arn               = var.node_role.arn
  subnet_ids                  = var.subnets

  scaling_config {
    desired_size              = var.eks_common.nodegroup.desired_size
    max_size                  = var.eks_common.nodegroup.max_size
    min_size                  = var.eks_common.nodegroup.min_size
  }
  update_config {
    max_unavailable           = var.eks_common.nodegroup.unavailable
  }

  tags = {
    Owner                     = "driskill@f5.com"
    Name                      = var.eks_common.name
  }
}

## Update kube-config file
resource "null_resource" "update_kubeconfig" {
  triggers = {
    cluster_name              = aws_eks_cluster.eks.id
    endpoint                  = aws_eks_cluster.eks.endpoint
  }

  provisioner "local-exec" {
    environment = {
      eks_endpoint            = aws_eks_cluster.eks.endpoint
    }

    command   = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.eks.id}"
  }
}
