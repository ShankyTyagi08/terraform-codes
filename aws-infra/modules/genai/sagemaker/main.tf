resource "aws_sagemaker_notebook_instance" "genai_notebook" {
  name                 = "genai-notebook"
  instance_type        = "ml.t2.medium"
  role_arn             = var.execution_role_arn
  subnet_id            = element(var.subnet_ids, 0)
  security_groups      = var.security_group_ids
  lifecycle_config_name = null

  tags = {
    Name = "GenAI Notebook"
  }
}
