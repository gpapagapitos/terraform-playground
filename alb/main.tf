provider "aws" {
  region = var.aws_region
}

data "template_file" "init" {
  template = file("script.sh")
}

resource "aws_instance" "instance_1" {
  ami           = "ami-06c68f701d8090592"
  instance_type = "t2.micro"

  vpc_security_group_ids = ["sg-0c73be0cd1ab583d8"]

  user_data = data.template_file.init.template

  tags = {
    Name      = "Instance 1"
    Terraform = "true"
  }
}

resource "aws_instance" "instance_2" {
  ami           = "ami-06c68f701d8090592"
  instance_type = "t2.micro"

  vpc_security_group_ids = ["sg-0c73be0cd1ab583d8"]

  user_data = data.template_file.init.template

  tags = {
    Name      = "Instance 2"
    Terraform = "true"
  }
}