resource "aws_key_pair" "myproject" {
  key_name   = "${var.project_name}-${var.project_env}"
  public_key = file("mykey.pub")
  tags = {
    Name = "${var.project_name}-${var.project_env}"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-${var.project_env}-sg"
  description = "${var.project_name} ${var.project_env} environment"

  # Ingress rules
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name        = "${var.project_name}-${var.project_env}-sg"
    Project     = var.project_name
    Environment = var.project_env
  }
}

# 🔹 EC2 Instance
resource "aws_instance" "my_ec2" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.latest.id
  key_name               = aws_key_pair.myproject.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name        = "${var.project_name}-${var.project_env}-ec2"
    Project     = var.project_name
    Environment = var.project_env
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "frontend" {
  zone_id = var.hosted_zone_id
  name    = "${var.hostname}.${var.hosted_zone_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.my_ec2.public_ip]
}
