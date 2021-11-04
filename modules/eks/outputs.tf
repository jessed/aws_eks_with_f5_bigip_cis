output "eks_sg_id"      { value = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id }
output "endpoint"       { value = null_resource.update_kubeconfig.triggers.endpoint }
