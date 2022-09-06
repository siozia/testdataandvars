provider "aws" {
  profile = "sre"
  region = var.provider_conf.region
}

terraform {
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.17.1"
    }
  }
}


data "aws_ssm_parameter" "db_address" {
  name = aws_ssm_parameter.db_address.name

}

data "aws_ssm_parameter" "db_port" {
  name =  aws_ssm_parameter.db_port.name
}

data "aws_ssm_parameter" "db_username" {
  name = aws_ssm_parameter.db_username.name
}

data "aws_ssm_parameter" "db_password" {
  name = aws_ssm_parameter.db_password.name
}

provider "postgresql" {
  host            = data.aws_ssm_parameter.db_address.value
  port            = data.aws_ssm_parameter.db_port.value
  username        = data.aws_ssm_parameter.db_username.value
  password        = data.aws_ssm_parameter.db_password.value
  sslmode         = "require"
  connect_timeout = 15
  superuser = false
}