provider "aws" {
  region = var.aws_region
}

data "template_file" "init" {
  template = file("script.sh")
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "subnet" {
  for_each = toset(data.aws_subnets.subnets.ids)
  id       = each.value
}

resource "aws_security_group" "nlb_sg" {
  name        = "demo-sg-nlb"
  description = "Allow HTTP into NLB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "launch_wizard_1" {
  name = "launch-wizard-1"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.nlb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "instance_1" {
  ami           = "ami-06c68f701d8090592"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.launch_wizard_1.id]

  user_data = data.template_file.init.template

  tags = {
    Name      = "Instance 1"
    Terraform = "true"
  }
}

resource "aws_instance" "instance_2" {
  ami           = "ami-06c68f701d8090592"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.launch_wizard_1.id]

  user_data = data.template_file.init.template

  tags = {
    Name      = "Instance 2"
    Terraform = "true"
  }
}

resource "aws_lb" "nlb" {
  name               = "DemoNLB"
  subnets            = [for subnet in data.aws_subnet.subnet : subnet.id]
  security_groups    = [aws_security_group.nlb_sg.id]
  load_balancer_type = "network"
}

resource "aws_lb_target_group" "nlb_tg" {
  name                 = "demo-tg-nlb"
  port                 = 80
  protocol             = "TCP"
  vpc_id               = data.aws_vpc.default.id
  deregistration_delay = 30
  target_type          = "instance"
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.nlb_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.nlb_tg.arn
  target_id        = aws_instance.instance_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.nlb_tg.arn
  target_id        = aws_instance.instance_2.id
  port             = 80
}

