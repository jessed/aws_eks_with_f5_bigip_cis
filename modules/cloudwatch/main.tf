# Create cloudwatch log group
resource "aws_cloudwatch_log_group" "eks" {
  name                      = var.cloudwatch.group_name
  retention_in_days         = var.cloudwatch.retention

  tags = {
    Name                    = var.cloudwatch.group_name
  }
}
