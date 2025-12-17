data "aws_route53_zone" "selected" {
  name         = "vishnuwedspreksha.art"
  private_zone = false
}
data "aws_ami" "example" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["${var.project_name}-${project_env}-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "tag:project"
    values = ["${var.project_name}"]
  }
  filter {
    name   = "tag:env"
    values = ["${var.project_env}"]
  }

}
