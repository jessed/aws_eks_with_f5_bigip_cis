eks = {
  # Elastice Kubernetes Service (eks) vars
  name              = "jessed_eks"
  cidr              = "10.200.0.0/16"

  # Elastic Container Registry (ecr) vars
  ecr = {
    name            = "jessed_ecr"
		mutability      = "MUTABLE"
    image_scan      = true
    policy_name     = "jesse_ecr_repo"
  }
}
