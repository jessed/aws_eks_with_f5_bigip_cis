terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  shared_credentials_file   = local.creds_file
  profile                   = local.profile
  region                    = var.region
  default_tags {
    tags = {
      Owner                 = var.owner
      Project               = var.project
    }
  }
}

# Create BIG-IP VPC
module "vpc" {
  source                    = "./modules/network"
  vpc                       = local.eks.vpc
  f5_common                 = local.f5_common
  eks                       = local.eks
}

# Create security groups
module "sg_mgmt" {
  source                    = "./modules/security_group"
  sg                        = var.secgroups.mgmt
  vpc_id                    = module.vpc.vpc_id
}

module "sg_data" {
  source                    = "./modules/security_group"
  sg                        = var.secgroups.eks
  vpc_id                    = module.vpc.vpc_id
}

# Create Bigip - ASG
module "asg" {
  source                    = "./modules/bigip"
  bigip                     = var.bigip
  f5_common                 = local.f5_common
  aws_f5_key                = var.aws_f5_key
  vpc                       = module.vpc.vpc_out
  mgmt_subnet               = module.vpc.mgmt_subnet
  data_subnet               = module.vpc.data_subnet
  sg_ids                    = [module.sg_mgmt.id,module.sg_data.id]
}

# Create EKS cluster policies and roles
module "iam" {
  source                    = "./modules/iam"
  f5_common                 = local.f5_common
  iam                       = var.iam
}

# Create Cloudwatch log group
module "logging" {
  source                    = "./modules/cloudwatch"
  cloudwatch                = local.cloudwatch
}

# Create EKS cluster and node-group
module "eks" {
  source                    = "./modules/eks"
  f5_common                 = local.f5_common
  eks_common                = local.eks
  subnets                   = [module.vpc.eks1_subnet.id, module.vpc.eks2_subnet.id]
  cluster_role              = module.iam.cluster_role
  node_role                 = module.iam.node_role
  region                    = var.region
  depends_on                = [module.iam, module.logging]
}

# Create container repository
module "ecr" {
  source                    = "./modules/ecr"
  ecr                       = var.eks.ecr
  region                    = var.region
}

provider "kubernetes" {
  host        = module.eks.endpoint
  config_path = "~/.kube/config"
}

# Kubernetes configuration
module "k8s" {
  source                    = "./modules/kubernetes"
  depends_on                = [module.eks, module.ecr]
}
