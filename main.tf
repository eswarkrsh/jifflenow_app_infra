# Provider and Access details
provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "tf_app_prov"
  }
}

resource "aws_subnet" "tf_app_subnet" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags {
    Name = "tf_app_subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "tf_app_ig"
  }
}
resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "aws_route_table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.tf_app_subnet.id}"
  route_table_id = "${aws_route_table.r.id}"
}

# Default Security Group to access
# the Instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "instance_tk"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access <-- anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access <-- anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound Internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ELB security group to access
# the ELB over HTTP
resource "aws_security_group" "elb" {
  name        = "elb_tk"
  description = "Used in the terraform"

  vpc_id = "${aws_vpc.default.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # VPC has an Internet gateway or fail
    depends_on = ["aws_internet_gateway.gw"]
  }

  resource "aws_elb" "web" {
  name = "tk-elb"

  # Availability zone as our instance
subnets = ["${aws_subnet.tf_app_subnet.id}"]

security_groups = ["${aws_security_group.elb.id}"]

listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
}

# Instance --> registered automatically

  instances                   = ["${aws_instance.web.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}

resource "aws_lb_cookie_stickiness_policy" "default" {
  name                     = "lbpolicy"
  load_balancer            = "${aws_elb.web.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

resource "aws_instance" "web" {
instance_type = "t2.micro"

# Lookup the correct AMI based on the region
  # we specified
ami = "${lookup(var.aws_amis, var.aws_region)}"

# SSH keypair created/downloaded
  # from the AWS console.
  key_name = "${var.key_name}"

  # Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id              = "${aws_subnet.tf_app_subnet.id}"
  user_data              = "${file("userdata.sh")}"

  #Instance tags

  tags {
    Name = "elb-tk"
  }
}
