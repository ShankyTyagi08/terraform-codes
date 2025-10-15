resource "aws_db_instance" "mysql" {
  identifier              = "mysql-instance"
  engine                  = "mysql"
  engine_version          = var.engine_version
  instance_class          = "db.t3.medium"
  allocated_storage       = 20
  skip_final_snapshot     = true
  publicly_accessible     = false

  vpc_security_group_ids  = var.security_group_ids
  db_subnet_group_name    = aws_db_subnet_group.mysql_subnet.name
}

resource "aws_db_subnet_group" "mysql_subnet" {
  name       = "mysql-subnet-group"
  subnet_ids = var.db_subnet_ids
}
