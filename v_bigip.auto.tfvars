# BIG-IP variables
bigip = {
  prefix                  = "eks-bigip"
  asg_name                = "eks-bigip"
  count                   = 1
  data_ip_count           = 0                         # Num of data-plane addresses (self + vs)
  asg_min                 = 1
  asg_max                 = 1
  monitor_grace_period    = 120

  domain                  = "us-west-2.compute.internal"
  ntp_server              = "tick.ucla.edu"
  timezone                = "America/Los_Angeles"

  ami                     = "ami-0a0b59d02e622f065"
  instance_type           = "t2.medium"
}
