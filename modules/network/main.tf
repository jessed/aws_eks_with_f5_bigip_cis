# create VPC
resource "aws_vpc" "main" {
  cidr_block                  = var.vpc.cidr
  instance_tenancy            = "default"
  enable_dns_hostnames        = true
  enable_dns_support          = true
  tags = {
    Name                      = var.vpc.name
  }
}

resource "aws_subnet" "mgmt" {
  vpc_id                      = aws_vpc.main.id
  cidr_block                  = var.vpc.mgmt_cidr
  availability_zone           = var.f5_common.zone
  tags = {
    Name                      = var.vpc.mgmt_name
  }
}

resource "aws_subnet" "data" {
  vpc_id                      = aws_vpc.main.id
  cidr_block                  = var.vpc.data_cidr
  availability_zone           = var.f5_common.zone
  tags = {
    Name                      = var.vpc.data_name
  }
}

resource "aws_subnet" "eks1" {
  vpc_id                      = aws_vpc.main.id
  cidr_block                  = var.vpc.eks_cidr1
  availability_zone           = var.vpc.eks_az1
  map_public_ip_on_launch     = true
  tags = {
    Name                      = var.vpc.eks_name1
    "kubernetes.io/cluster/${var.eks.name}" = "shared"
  }
}

resource "aws_subnet" "eks2" {
  vpc_id                      = aws_vpc.main.id
  cidr_block                  = var.vpc.eks_cidr2
  availability_zone           = var.vpc.eks_az2
  map_public_ip_on_launch     = true
  tags = {
    Name                      = var.vpc.eks_name2
    "kubernetes.io/cluster/${var.eks.name}" = "shared"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id                      = aws_vpc.main.id
  tags = {
    Name                      = var.vpc.igw_name
  }
}

resource "aws_default_route_table" "rtb" {
  default_route_table_id      = aws_vpc.main.default_route_table_id
  tags = {
    Name                      = var.vpc.rtb_name
  }
}

resource "aws_route" "route" {
  route_table_id              = aws_default_route_table.rtb.id
  destination_cidr_block      = "0.0.0.0/0"
  gateway_id                  = aws_internet_gateway.igw.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options
resource "aws_vpc_dhcp_options" "eks_options" {
  domain_name                 = var.f5_common.domain
  domain_name_servers         = ["AmazonProvidedDNS"]

  tags = {
    Name                      = "jesse_dhcp_options"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association
resource "aws_vpc_dhcp_options_association" "eks_options" {
  vpc_id                      = aws_vpc.main.id
  dhcp_options_id             = aws_vpc_dhcp_options.eks_options.id
}
