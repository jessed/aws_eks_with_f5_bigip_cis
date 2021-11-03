secgroups = {
  mgmt = {
    name            = "jessed-mgmt_sg"
    allowed_cidr    = ["24.16.243.5/32"]
    ports = {
      "22"          = "TCP"
      "443"         = "TCP"
      "8443"        = "TCP"
    }
  }
  eks = {
    name            = "jessed-eks_sg"
    allowed_cidr    = ["0.0.0.0/0"]
    ports = {
      "80"          = "TCP"
      "443"         = "TCP"
    }
  }
}

