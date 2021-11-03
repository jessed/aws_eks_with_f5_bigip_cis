# IAM role policy

## Create IAM role policies
#
# Create IAM EKS cluster role policy
resource "local_file" "eks_cluster_role_policy" {
  content                 = file("${path.root}/templates/eks_cluster_role.json")
  filename                = "${path.root}/work_tmp/eks_cluster_role.json"
}

# Create IAM EKS node role policy
resource "local_file" "eks_node_role_policy" {
  content                 = file("${path.root}/templates/eks_node_role.json")
  filename                = "${path.root}/work_tmp/eks_node_role.json"
}


## Create IAM EKS roles
#
# Create IAM EKS Cluster roles
resource "aws_iam_role" "eks_cluster_role" {
  name                    = var.iam.eks_cluster_role
  assume_role_policy      = local_file.eks_cluster_role_policy.content
  force_detach_policies   = true

  tags = {
    "Name"                = var.iam.eks_cluster_role
  }
}

# Create IAM EKS Node role
resource "aws_iam_role" "eks_node_role" {
  name                    = var.iam.eks_node_role
  assume_role_policy      = local_file.eks_node_role_policy.content
  force_detach_policies   = true

  tags = {
    "Name"                = var.iam.eks_node_role
  }
}

/*
## Create IAM EKS policies
#
# Create IAM EKS Cluster Policy
resource "aws_iam_policy" "eks_cluster_policy" {
  name                    = var.iam.eks_cluster_policy
  policy                  = file("${path.root}/templates/eks_cluster_policy.json")
}

# Create IAM EKS Node Policy
resource "aws_iam_policy" "eks_node_policy" {
  name                    = var.iam.eks_node_policy
  policy                  = file("${path.root}/templates/eks_node_policy.json")
}
*/

## Attach IAM Policies to Roles
#
# Attach EKS Cluster Policy to Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attach" {
  role                    = aws_iam_role.eks_cluster_role.name
  #policy_arn              = aws_iam_policy.eks_cluster_policy.arn
  policy_arn              = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Attach EKS Node Policy to Node Role
resource "aws_iam_role_policy_attachment" "eks_node_container_policy_attach" {
  role                    = aws_iam_role.eks_node_role.name
  #policy_arn              = aws_iam_policy.eks_node_policy.arn
  policy_arn              = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "eks_node_worker_policy_attach" {
  role                    = aws_iam_role.eks_node_role.name
  policy_arn              = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "eks_node_cni_policy_attach" {
  role                    = aws_iam_role.eks_node_role.name
  policy_arn              = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
