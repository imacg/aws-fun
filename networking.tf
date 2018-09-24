resource "aws_vpc" "aws_fun" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id = "${aws_vpc.aws_fun.id}"
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = "ca-central-1${element(list("a", "b"), count.index)}"
  count = 2
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.aws_fun.id}"
}

resource "aws_default_route_table" "r" {
  default_route_table_id = "${aws_vpc.aws_fun.id}"

  route {
    cidr_block = "10.0.0.0/16"
  }
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}
