provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "instance_1" {
  ami           = "ami-0cff7528ff583bf9a"
  instance_type = "t2.micro"

  tags = {
    Name      = "Example 1"
    Terraform = "true"
  }
}

resource "aws_instance" "instance_2" {
  ami           = "ami-0cff7528ff583bf9a"
  instance_type = "t2.micro"

  tags = {
    Name      = "Example 2"
    Terraform = "true"
  }
}