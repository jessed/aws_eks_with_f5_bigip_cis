# Create BIG-IP(s)

# Create bigip instance
resource "aws_instance" "bigip" {
  count                       = var.bigip.count
  ami                         = var.bigip.use_paygo == true ? var.bigip.paygo-ami : var.bigip.byol-ami
  instance_type               = var.bigip.instance_type
  key_name                    = var.f5_common.key
  subnet_id                   = var.mgmt_subnet.id
  availability_zone           = var.f5_common.zone
  vpc_security_group_ids      = var.sg_ids
  associate_public_ip_address = true
  #iam_instance_profile        = var.instance_profile.name

  user_data_base64            = base64gzip(local_file.ltm_cloud_init[count.index].content)

  tags = {
    Name                      = format("${var.bigip.prefix}%02d", count.index+1)
    hostname                  = format("${var.bigip.prefix}%02d.%s", count.index+1, var.bigip.domain)
    owner                     = var.f5_common.owner
  }

  # update local hosts file
  provisioner "local-exec" {
    command                   = "${path.root}/scripts/update_hosts.bash ${self.tags.Name} ${self.public_ip}"
  }

  # Revoke license on BIG-IQ
  # This will run (and fail) with paygo images, but the failure shouldn't impact 
  # terraform completion
  provisioner "local-exec" {
    when                      = destroy
    #command                   = "${path.root}/scripts/revoke_license.bash ${self.public_ip} ${var.bigiq.host} ${var.bigip.use_paygo}"

    # TF doesn't let a destroy action reference external variables -__-
    command                   = "${path.root}/scripts/revoke_license.bash ${self.public_ip}"
    on_failure                = continue
  }
}

# create data-plane interface
resource "aws_network_interface" "data_plane" {
  count                       = var.bigip.count
  description                 = format("${var.bigip.prefix}%02d_data_nic", count.index+1)
  subnet_id                   = var.data_subnet.id
  private_ips_count           = var.bigip.data_ip_count
  security_groups             = var.sg_ids
}

# Attach interface as a separate operation
resource "aws_network_interface_attachment" "data_plane" {
  count                       = var.bigip.count
  instance_id                 = aws_instance.bigip.*.id[count.index]
  network_interface_id        = aws_network_interface.data_plane.*.id[count.index]
  device_index                = 1
}


