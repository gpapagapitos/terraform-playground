provider "aws" {
  region = var.aws_region
}

data "template_file" "init" {
  template = file("script.sh")
}

data "aws_vpc" "default" {
  default = true
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

resource "aws_instance" "instance_3" {
  ami           = "ami-06c68f701d8090592"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.launch_wizard_1.id]

  user_data = data.template_file.init.template

  tags = {
    Name      = "Instance 3"
    Terraform = "true"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "demo-sg-load-balancer"
  description = "Allow HTTP into ALB"

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
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb_target_group" "alb_tg" {
  name                 = "demo-tg-alb"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.default.id
  deregistration_delay = 30
  target_type          = "instance"

  stickiness {
    type = "lb_cookie"
    enabled = true
    cookie_duration = 86400
  }
}

resource "aws_alb_target_group_attachment" "instance_1" {
  target_group_arn = aws_alb_target_group.alb_tg.arn
  target_id        = aws_instance.instance_1.id
  port             = 80
}

resource "aws_alb_target_group_attachment" "instance_2" {
  target_group_arn = aws_alb_target_group.alb_tg.arn
  target_id        = aws_instance.instance_2.id
  port             = 80
}

resource "aws_alb_target_group_attachment" "instance_3" {
  target_group_arn = aws_alb_target_group.alb_tg.arn
  target_id        = aws_instance.instance_3.id
  port             = 80
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_tg.arn
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "rule" {
  tags         = { name = "DemoRule" }
  listener_arn = aws_alb_listener.alb_listener.arn
  priority     = 1

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "NOT FOUND 404!! (custom error)"
      status_code  = "404"
    }
  }

  condition {
    path_pattern {
      values = ["/error"]
    }
  }

}

resource "aws_alb" "alb" {
  name               = "DemoALB"
  subnets            = ["subnet-0c6fbb9ea5983b85c", "subnet-017c1747d6f3e0bd3", "subnet-053036c966707cc0f", "subnet-04d23d5a74143b17c", "subnet-01c3b2698a08cb6cb", "subnet-06303e382ed0cad39"]
  security_groups    = [aws_security_group.alb_sg.id]
  load_balancer_type = "application"
}
