
# AWS defaults 
variable "owner"            { default = "driskill@f5.com" }
variable "region"           { default = "us-west-2" }
variable "avail_zone"       { default = "us-west-2a" }
variable "aws_f5_key"       { default = "jesse-aws" }
variable "domain"           { default = "aws.jessnet.net" }

# Global vars
variable "project"          { default = "eks_cis" }
variable "allowed_src"      { default = ["24.16.243.5/32","73.225.163.106/32", "97.115.100.253/32"] }
variable "public_domain"    { default = "eks.jessnet.net" }

# Import the local secrets file
locals {
  secrets                   = jsondecode(file("${path.module}/secrets.json"))
  creds_file                = local.secrets.credentials
  profile                   = local.secrets.profile_name
}

# VPC vars
locals {
  eks = {
    name                    = var.eks.name
    nodegroup = {
      name                  = format("%s-nodegroup", var.eks.name)
      min_size              = 2
      max_size              = 2
      desired_size          = 2
      unavailable           = 2
    }
    vpc = {
      name                  = var.eks.name
      cidr                  = var.eks.cidr
      rtb_name              = "eks_rtb"
      igw_name              = "eks_igw"
      secure_src            = flatten([var.allowed_src])
      sec_group             = "jessnet_eks_secgrp"
      mgmt_name             = "${var.eks.name}.mgmt"
      mgmt_cidr             = cidrsubnet(var.eks.cidr, 8, 0)    # x.x.0.0/24
      data_name             = "${var.eks.name}.data"
      data_cidr             = cidrsubnet(var.eks.cidr, 8, 10)   # x.x.10.0/24
      eks_name1             = "${var.eks.name}.eks1"
      eks_cidr1             = cidrsubnet(var.eks.cidr, 8, 30)   # x.x.30.0/24
      eks_az1               = "us-west-2a"
      eks_name2             = "${var.eks.name}.eks2"
      eks_cidr2             = cidrsubnet(var.eks.cidr, 8, 31)   # x.x.31.0/24
      eks_az2               = "us-west-2b"
    }
  }
  cloudwatch = {
    group_name            = "/aws/eks/${var.eks.name}/cluster"
    retention             = 7
  }

  secure_src                = [ "24.16.243.5/32","73.225.163.106/32"]
  all                       = [ "0.0.0.0/0" ]

  f5_common = {
    owner                   = var.owner
    owner_id                = local.secrets.owner_id
    region                  = var.region
    zone                    = var.avail_zone
    key                     = var.aws_f5_key
    bigip_user              = local.secrets.bigip_user
    bigip_pass              = local.secrets.bigip_pass
    domain                  = var.domain

    cloud_storage_path      = ""

    cloud_init_log          = "cloud-init.log"
    cfg_dir                 = "/shared/cloud_init"
    DO_pkg                  = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.24.0/f5-declarative-onboarding-1.24.0-6.noarch.rpm"
    AS3_pkg                 = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.31.0/f5-appsvcs-3.31.0-6.noarch.rpm"
    TS_pkg                  = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.23.0/f5-telemetry-1.23.0-4.noarch.rpm"
    ts_region               = var.region
    ts_type                 = "AWS_CloudWatch"
    ts_log_group            = "f5telemetry"
    ts_log_stream           = "default"
    ts_username             = "accesskey"
    ts_passphrase           = "ciphertext"
  }
  bigiq = {                 # BIG-IQ License Manager (for BYOL licensing)
    host                    = local.secrets.bigiq_host
    user                    = local.secrets.bigiq_user
    pass                    = local.secrets.bigiq_pass
    lic_type                = "licensePool"
    lic_pool                = "azure_test"
    lic_measure             = "yearly"
    lic_hypervisor          = "aws"
    reachable               = false
		project									= var.project
  }
}

variable "iam" {
  default = {
    eks_cluster_role        = "jesse_eks_cluster_role"
    eks_cluster_policy      = "jesse_eks_cluster_policy"
    eks_node_role           = "jesse_eks_node_role"
    eks_node_policy         = "jesse_eks_node_policy"
  }
}

variable "bigip"            {}
variable "secgroups"        {}
variable "eks"              {}
