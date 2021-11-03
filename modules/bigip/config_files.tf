# Config files to be created from templates

# System Onboarding script
resource "local_file" "ltm_cloud_init" {
  content = templatefile("${path.root}/templates/bigip_cloud_init_asg.template", {
    cloud_init_log                = var.f5_common.cloud_init_log
    admin_user                    = var.f5_common.bigip_user
    admin_password                = var.f5_common.bigip_pass
    use_cloud_storage             = var.f5_common.use_cloud_storage
    use_cloud_config              = var.f5_common.use_cloud_config
    ltm_cloud_config              = var.f5_common.ltm_cloud_config
    LTM_cfg_blob                  = var.f5_common.blob_name
    ACR                           = var.f5_common.ACR
    DO_FN                         = var.f5_common.DO_file
    TS_FN                         = var.f5_common.TS_file
    AS3_FN                        = var.f5_common.AS3_file
    CFG_DIR                       = var.f5_common.cfg_dir
    DO_conf                       = ""
    AS3_conf                      = ""
    TS_conf                       = ""
    LTM_Config                    = ""
  })
  filename                        = "${path.root}/work_tmp/bigip_cloud_init.bash"
}


/*
# Declarative-Onboarding config
resource "local_file" "do_json" {
  content = templatefile("${path.root}/templates/do.json", {
    local_host                    = format("${var.bigip.prefix}%02d.%s", count.index+1, var.bigip.domain)
    local_selfip                  = element(aws_network_interface.data_plane[count.index].private_ip.*, 0)
    data_gateway                  = cidrhost(var.data_subnet.cidr_block, 1)
    ntp_server                    = var.bigip.ntp_server
    timezone                      = var.bigip.timezone
    bigIpUser                     = var.f5_common.bigip_user
    bigIpPass                     = var.f5_common.bigip_pass
  })
  filename                        = "${path.root}/work_tmp/do${count.index}.json"
}

# AS3 configuration
resource "local_file" "as3_json" {
  count   = var.bigip.count
  content = templatefile("${path.root}/templates/as3.json", {
    REMARK                        = "Service discovery"
    APP                           = "aws"
    PARTITION                     = "aws"
    ASGGROUP                      = var.bigip.asg_name
    VS_NAME                       = local.aws.bigip.vs_name
    VS_ADDR                       = aws_network_interface.data_plane[count.index].private_ip
    POOL                          = "pool"
    MONITOR                       = "tcp"
    REGION                        = var.region
    IAMROLEARN                    = aws_iam_role.bigip_iam_role.arn
    IAMEXTERNALID                 = local.aws.external_id
  })
  filename                        = "${path.root}/work_tmp/as3${count.index}.json"
}

# LTM configuration
resource "local_file" "ltm_config" {
  count                           = var.bigip.count
  content = templatefile("${path.root}/templates/ltm_config.conf-template", {
    #self_ip                       = element(aws_network_interface.data_plane[count.index].private_ip.*, 0)
  })
  filename                        = "${path.root}/work_tmp/ltm_config.conf"
}

# update license script
resource "local_file" "update_license" {
  content = templatefile("${path.root}/templates/update_license.tpl", {
    bigIqHost                     = var.f5_common.bigiq_host
    bigIqUser                     = var.f5_common.bigiq_user
    bigIqPass                     = var.f5_common.bigiq_pass
    bigIpUser                     = var.f5_common.bigip_user
    bigIpPass                     = var.f5_common.bigip_pass
  })
  filename                        = "${path.root}/work_tmp/f5_update_license.bash"
}
*/
