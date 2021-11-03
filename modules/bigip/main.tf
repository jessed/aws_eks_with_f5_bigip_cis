# Create BIG-IP(s)

## launch template
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template

resource "aws_launch_template" "bigip" {
  name_prefix                   = var.bigip.prefix
  image_id                      = var.bigip.ami
  instance_type                 = var.bigip.instance_type
  key_name                      = var.aws_f5_key
  user_data                     = base64gzip(local_file.ltm_cloud_init.content)

  instance_initiated_shutdown_behavior = "terminate"

#  iam_instance_profile {
#    name                        = var.instance_profile.name
#  }

  tags = {
    Name                        = var.bigip.prefix
    service                     = "nva"
  }

  network_interfaces {
    description                 = "Management interface"
    subnet_id                   = var.mgmt_subnet.id
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = var.sg_ids
    device_index                = 0
  }

# Cannot assign public addresses if two network interfaces are in use
#  network_interfaces {
#    description                 = "Dataplane interface"
#    subnet_id                   = var.data_subnet.id
#    associate_public_ip_address = false
#    delete_on_termination       = true
#    security_groups             = var.sg_ids
#    device_index                = 1
#  }
}

## auto-scaling group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "asg" {
  name                          = var.bigip.asg_name
  vpc_zone_identifier           = [var.mgmt_subnet.id, var.data_subnet.id]
  min_size                      = var.bigip.asg_min
  max_size                      = var.bigip.asg_max
  force_delete                  = true
  health_check_grace_period     = var.bigip.monitor_grace_period

  lifecycle {
    create_before_destroy       = true
    ignore_changes              = [load_balancers, target_group_arns]
  }

  launch_template {
    id                          = aws_launch_template.bigip.id
    version                     = "$Latest"
  }

  tag {
    key                         = "Name"
    value                       = var.bigip.asg_name
    propagate_at_launch         = true
  }
}

