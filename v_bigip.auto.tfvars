# BIG-IP variables
bigip = {
  instance_type           = "t2.medium"

  paygo-ami               = "ami-0a0b59d02e622f065" # F5 BIGIP-15.1.2.1-0.0.10 PAYG-Good 25Mbps-210115154531
  byol-ami                = "ami-094357dd181742a06" # F5 BIGIP-15.1.2-0.0.9 BYOL-LTM 1Boot Loc-201110222845

  # Will deploy one or more independent BIG-IP instance(s) if an ASG is not used. 
  use_asg                 = false

  # If true, use paygo AMI. If false, use BYOL ami
  use_paygo               = true

  # These variables are used when 'use_asg' = false
  prefix                  = "eksltm"
  count                   = 1
  data_ip_count           = 0                         # Num of data-plane addresses (self + vs)

  # These variables are used when 'use_asg' = true
  asg_name                = "eks-bigip"
  asg_min                 = 1
  asg_max                 = 1
  monitor_grace_period    = 120

  # These apply whether or not an ASG is used
  domain                  = "us-west-2.compute.internal"
  ntp_server              = "tick.ucla.edu"
  timezone                = "America/Los_Angeles"

}
