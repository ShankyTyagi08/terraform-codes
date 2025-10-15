resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = var.engine_version
  master_username         = "admin"
  master_password         = "Aurora1234!"
  database_name           = var.db_name
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet.id
  vpc_security_group_ids  = var.security_group_ids
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count                   = 2
  identifier              = "aurora-instance-${count.index + 1}"
  cluster_identifier      = aws_rds_cluster.aurora.id
  instance_class          = "db.r5.large"
  engine                  = "aurora-mysql"
}

resource "aws_db_subnet_group" "aurora_subnet" {
  name       = "aurora-subnet-group"
  subnet_ids = var.db_subnet_ids
}