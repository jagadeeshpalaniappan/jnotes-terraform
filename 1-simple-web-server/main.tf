provider "aws" {
  region = "us-east-1"
  # access_key = "xxxxx"
  # secret_key = "yyyyy"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# 6. Create Security Group to allow port 80
resource "aws_security_group" "jag_sg_allow_http" {
  name        = "allow_web_traffic"
  description = "Allow HTTP 80 traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "HTTP"
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

  tags = {
    Name = "jag-web-sg-1"
  }
}

resource "aws_instance" "jag_ins_dev_ws_1" {
  ami                         = "ami-085925f297f89fce1" # get the latest ami from aws console
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.jag_sg_allow_http.name]
  associate_public_ip_address = true

  # user_data = <<-EOF
  #                 #!/bin/bash
  #                 sudo su
  #                 yum -y install httpd
  #                 echo "<p> My Instance! </p>" >> /var/www/html/index.html
  #                 sudo systemctl enable httpd
  #                 sudo systemctl start httpd
  #                 EOF

  user_data = <<-EOF
                  #!/bin/bash
                  sudo apt update -y
                  sudo apt install apache2 -y
                  sudo systemctl start apache2
                  sudo bash -c 'echo My very first web server > /var/www/html/index.html'
                  EOF

  tags = {
    Name = "jag-dev-ws-1"
  }
}

output "DNS" {
  value = aws_instance.jag_ins_dev_ws_1.public_dns
}
