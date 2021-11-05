# Config files to be created from templates

# System Onboarding script
resource "local_file" "ltm_cloud_init" {
  content = templatefile("${path.root}/templates/bigip_cloud_init.template", {
    hostname                      = "${var.bigip.asg_name}.${var.f5_common.domain}"
    cloud_init_log                = var.f5_common.cloud_init_log
    admin_user                    = var.f5_common.bigip_user
    admin_password                = var.f5_common.bigip_pass
    cloud_storage_path            = var.f5_common.cloud_storage_path
    do_iapp_pkg                   = var.f5_common.DO_pkg
    ts_iapp_pkg                   = var.f5_common.TS_pkg
    as3_iapp_pkg                  = var.f5_common.AS3_pkg
    CFG_DIR                       = var.f5_common.cfg_dir
    DO_conf                       = base64encode(local_file.do_json.content)
    AS3_conf                      = try(filebase64("${path.root}/templates/as3.json"), "")
    TS_conf                       = ""
    ltm_config_b64                = try(filebase64("${path.root}/templates/ltm_config.conf-template"), "")
    license_update_script_b64     = try(base64encode(local_file.license_script[0].content), "")
    license_update_service_b64    = try(local_file.license_service[0].content, "")
  })
  filename                        = "${path.root}/work_tmp/bigip_cloud_init.bash"
}


# Declarative-Onboarding config
resource "local_file" "do_json" {
  content = templatefile("${path.root}/templates/do.json", {
    dataplane_network             = try(local_file.do-networking[0].content, "")
    licensing                     = try(local_file.do-licensing[0].content, "")
    ntp_server                    = var.bigip.ntp_server
    timezone                      = var.bigip.timezone
    bigIpUser                     = var.f5_common.bigip_user
    bigIpPass                     = var.f5_common.bigip_pass
  })
  filename                        = "${path.root}/work_tmp/do.json"
}

# If an asg is *not* in-use, import the data-plane network config
resource "local_file" "do-networking" {
  count                           = var.bigip.use_asg == false ? 1 : 0
  content = templatefile("${path.root}/templates/do-networking.json", {
    data_gateway                  = cidrhost(var.data_subnet.cidr_block, 1)
  })
  filename                        = "${path.root}/work_tmp/do-networking.json"
}

# If byol *is* in-use, import the licensing configuration
resource "local_file" "do-licensing" {
  count                           = var.bigip.use_paygo == true ? 1 : 0
  content = templatefile("${path.root}/templates/do-byol-licensing.json", {
    bigIQ_Host                    = var.bigiq.host
    bigIQ_Username                = var.bigiq.user
    bigIQ_Password                = var.bigiq.pass
    bigIQ_LicenseType             = var.bigiq.lic_type
    bigIQ_LicensePool             = var.bigiq.lic_pool
    bigIQ_UnitOfMeasure           = var.bigiq.lic_measure
    bigIQ_Hypervisor              = var.bigiq.lic_hypervisor
    bigIP_User                    = var.f5_common.bigip_user
    bigIP_Pass                    = var.f5_common.bigip_pass
  })
  filename                        = "${path.root}/work_tmp/do-licensing.json"
}

# If byol *is* used, create the license script and service
resource "local_file" "license_script" {
  count                           = var.bigip.use_paygo == true ? 1 : 0
  content = templatefile("${path.root}/templates/byol-license.bash-template", {
    bigIQ_Host                    = var.bigiq.host
    bigIQ_User                    = var.bigiq.user
    bigIQ_Pass                    = var.bigiq.pass
    bigIP_User                    = var.f5_common.bigip_user
    bigIP_Pass                    = var.f5_common.bigip_pass
    project                       = var.bigiq.project
  })
  filename                        = "${path.root}/work_tmp/license_service_script.bash"
}

resource "local_file" "license_service" {
  count                           = var.bigip.use_paygo == true ? 1 : 0
  content                         = filebase64("${path.root}/templates/byol-license.service")
  filename                        = "${path.root}/work_tmp/license.service"
}

/*
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
*/
