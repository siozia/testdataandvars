data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "education"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}


resource "aws_db_subnet_group" "education" {
  name       = "education"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "Education"
  }
}


resource "aws_db_instance" "education" {
  identifier             = var.rds.confs.identifier
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "13.3"
  username               = "education"
  password               = var.rds.confs.db_password
  db_subnet_group_name   = aws_db_subnet_group.education.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.education.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}


resource "aws_db_parameter_group" "education" {
  name   = "education"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}


resource "aws_security_group" "rds" {
  name   = "education_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "education_rds"
  }
}

resource "aws_ssm_parameter" "db_address" {
  name = "education_address"
  value = aws_db_instance.education.address
  type = "String"
}

resource "aws_ssm_parameter" "db_port" {
  name = "education_port"
  value = aws_db_instance.education.port
  type = "String"
}

resource "aws_ssm_parameter" "db_username" {
  name = "education_username"
  value = aws_db_instance.education.username
  type = "String"
}

resource "aws_ssm_parameter" "db_password" {
  name = "education_password"
  value = aws_db_instance.education.password
  type = "String"
}

resource "postgresql_role" "my_role" {
  name     = "my_role"
  login    = true
  password = "mypass"
}
