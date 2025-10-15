resource "tls_private_key" "infra_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "infra_keypair" {
  key_name   = "infra"  # Name of the keypair in AWS
  public_key = tls_private_key.infra_key.public_key_openssh
}

resource "local_file" "infra_private_key" {
  content  = tls_private_key.infra_key.private_key_pem
  filename = "${path.module}/infra.pem"

  file_permission = "0400"  # Set appropriate permissions
}