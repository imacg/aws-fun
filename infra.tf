resource "aws_key_pair" "deploy" {
  key_name = "aws_fun_deploy"
  public_key = "${file("creds/deploy.pub")}"
}

resource "aws_alb" "lb" {
  name_prefix = "lb"
  internal = false

  load_balancer_type = "application"
  subnets = [ "${aws_subnet.subnet.*.id}" ]
  security_groups = [ "${aws_security_group.http_https.id}" ]

  depends_on = [ "aws_internet_gateway.gw" ]
  
  tags {
    Name = "aws-fun"
    Project = "aws-fun"
  }
}

resource "aws_alb_listener" "http" {
  port = 80
  load_balancer_arn = "${aws_alb.lb.arn}"
  
  default_action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.machines.arn}"
  }
}

resource "aws_alb_target_group" "machines" {
  name = "machines"
  port = 3000
  protocol = "HTTP"
  vpc_id = "${aws_vpc.aws_fun.id}"
}

resource "aws_security_group" "http_https" {
  name = "allow http/s"
  vpc_id = "${aws_vpc.aws_fun.id}"
  description = "allow http and https"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
    
resource "aws_security_group" "hello_world" {
  name = "hello world"
  vpc_id = "${aws_vpc.aws_fun.id}"
  description = "allow ssh and port 3000"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group_attachment" "attachment" {
  target_group_arn = "${aws_alb_target_group.machines.arn}"
  target_id = "${aws_instance.hello_machine.*.id[count.index]}"

  count = "${length(aws_instance.hello_machine.*.id)}"
}

resource "aws_instance" "hello_machine" {
  ami = "ami-aca72ac8"
  instance_type = "t2.nano"
  associate_public_ip_address = true
  key_name = "${aws_key_pair.deploy.key_name}"
  subnet_id = "${aws_subnet.subnet.*.id[0]}"
  vpc_security_group_ids = [ "${aws_security_group.hello_world.id}" ]
  
  tags {
    Name = "aws-fun"
    Project = "aws-fun"
  }

  count = 2
}
