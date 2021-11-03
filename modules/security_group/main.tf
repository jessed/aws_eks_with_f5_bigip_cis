resource "aws_security_group" "default" {
  name                        = var.sg.name
  vpc_id                      = var.vpc_id

  tags = {
    Name                      = var.sg.name
  }
}

resource "aws_security_group_rule" "ingress" {
  type                        = "ingress"
  security_group_id           = aws_security_group.default.id
  for_each = var.sg.ports
    from_port                 = each.key
    to_port                   = each.key
    protocol                  = each.value
    cidr_blocks               = var.sg.allowed_cidr
}

resource "aws_security_group_rule" "allow_self" {
  type                        = "ingress"
  security_group_id           = aws_security_group.default.id
  from_port                   = 0
  to_port                     = 0
  protocol                    = -1
  self                        = true
}

resource "aws_security_group_rule" "egress_all" {
  type                        = "egress"
  security_group_id           = aws_security_group.default.id
  from_port                   = 0
  to_port                     = 0
  protocol                    = -1
  cidr_blocks                 = ["0.0.0.0/0"]
}
