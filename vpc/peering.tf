# this example creates two VPCs TEST_VPC1 and TEST_VPC2 with peering feature enabled between both of them


provider "aws" {}

variable "subnet1" {
    default =   "192.168.1.0/24"
  
}

variable "subnet2" {
    default =   "192.168.2.0/24"
  
}


##VPC1

resource "aws_vpc" "vpc1" {

    cidr_block  =   "${var.subnet1}"
    tags {
        Name    =   "TEST_VPC1"
    }
  
}

resource "aws_subnet" "vpc1" {
    cidr_block  =   "${var.subnet1}"
    vpc_id      =   "${aws_vpc.vpc1.id}"
    map_public_ip_on_launch =   true
  
}


resource "aws_internet_gateway" "igw1" {
    vpc_id      =   "${aws_vpc.vpc1.id}"
}

resource "aws_route_table" "vpc1" {
    vpc_id       =  "${aws_vpc.vpc1.id}"

    tags {
        Name    =   "main"
    }

    route {
        cidr_block  =   "${var.subnet2}"
        vpc_peering_connection_id   =   "${aws_vpc_peering_connection.peer_vpc1vpc2.id}"

    }

    route {
        cidr_block  =   "0.0.0.0/0"
        gateway_id  =   "${aws_internet_gateway.igw1.id}"
    }
  
}


resource "aws_main_route_table_association" "vpc1" {
  vpc_id         = "${aws_vpc.vpc1.id}"
  route_table_id = "${aws_route_table.vpc1.id}"
}


#############################################
##VPC2
resource "aws_vpc" "vpc2" {
    cidr_block  =   "${var.subnet2}"
    tags {
        Name    =   "TEST_VPC2"
    }
  
}


resource "aws_subnet" "vpc2" {
    cidr_block  =   "${var.subnet2}"
    vpc_id      =   "${aws_vpc.vpc2.id}"
  
}

resource "aws_route_table" "vpc2" {
    vpc_id  =   "${aws_vpc.vpc2.id}"

    tags {
        Name    =   "main"
    }

    route {
        cidr_block  =   "${var.subnet1}"
        vpc_peering_connection_id   =   "${aws_vpc_peering_connection.peer_vpc1vpc2.id}"
    }
  
}

resource "aws_main_route_table_association" "vpc2" {
  vpc_id         = "${aws_vpc.vpc2.id}"
  route_table_id = "${aws_route_table.vpc2.id}"
}

############################################


resource "aws_vpc_peering_connection" "peer_vpc1vpc2" {
    auto_accept =   true
    peer_vpc_id =   "${aws_vpc.vpc2.id}"
    vpc_id      =   "${aws_vpc.vpc1.id}"
    tags {
        Name    =   "peer vpc1<->vpc2"
    }
  
}

