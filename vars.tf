


# AWS defaults 
variable "owner"            { default = "driskill@f5.com" }
variable "owner_id"         { default = "065972273535" }
variable "region"           { default = "us-west-2" }
variable "avail_zone"       { default = "us-west-2a" }
variable "aws_f5_key"       { default = "jesse-aws" }

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
    owner_id                = var.owner_id
    region                  = var.region
    zone                    = var.avail_zone
    key                     = var.aws_f5_key
    bigip_user              = local.secrets.bigip_user
    bigip_pass              = local.secrets.bigip_pass

    s3_bucket               = "jesse-eks"

    use_cloud_storage       = 0
    use_cloud_config        = 1
    ltm_cloud_config        = "ltm_config.conf-template"

    cloud_init_log          = "cloud-init.log"
    blob_name               = "ltm_config.conf-template"   # cloud storage config blob
    cfg_dir                 = "/shared/cloud_init"
    ACR                     = "unused"
    DO_file                 = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.15.0/f5-declarative-onboarding-1.15.0-3.noarch.rpm"
    AS3_file                = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.22.1/f5-appsvcs-3.22.1-1.noarch.rpm"
    TS_file                 = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.14.0/f5-telemetry-1.14.0-2.noarch.rpm"
    ts_region               = "us-west-2"
    ts_type                 = "AWS_CloudWatch"
    ts_log_group            = "f5telemetry"
    ts_log_stream           = "default"
    ts_username             = "accesskey"
    ts_passphrase           = "ciphertext"
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
