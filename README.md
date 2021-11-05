# AWS EKS Deployment

## Overview

## Pre-deployment steps
- Run 'aws sso login' prior to deployment to ensure AWS CLI access
- Update variable files to customize settings
  - vars.tf
  - v_bigip.auto.tfvars
  - v_eks.auto.tfvars
  - v_secgroups.auto.tfvars




## Important Notes
- The user-data script (templates/bigip_cloud_init.template) assumes only a single data-plane interface is present. 
  - This limits support to 1-nic and 2-nic deployments
