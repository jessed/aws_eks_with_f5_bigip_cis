# Create ECR policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy
resource "local_file" "ecr_policy" {
  content = templatefile("${path.root}/templates/ecr_container_policy.json", {
    ecr_policy_name           = var.ecr.policy_name
  })
  filename                    = "${path.root}/work_tmp/ecr_policy.json"
}

# Create ECR
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
resource "aws_ecr_repository" "main" {
  name                        = var.ecr.name
  image_tag_mutability        = var.ecr.mutability

  image_scanning_configuration {
    scan_on_push              = var.ecr.image_scan
  }

  tags = {
    Name                      = var.ecr.name
  }
}

resource "aws_ecr_repository_policy" "ecr_policy" {
  repository                  = aws_ecr_repository.main.name
  policy                      = local_file.ecr_policy.content
}


# Update local docker authorization
resource "null_resource" "docker_auth" {
  triggers = {
    ecr_url = aws_ecr_repository.main.repository_url
  }

  provisioner "local-exec" {
    environment = {
      ECR_NAME = split("/", aws_ecr_repository.main.repository_url)[0]
    }

    command = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin $ECR_NAME"
  }
}
