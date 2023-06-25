provider "aws" {
  
region = "ap-south-1"
profile = "default"
#   access_key = "AKIAWPKEV2QCWWHILPDP"
#   secret_key = "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"

} 

variable "subnet_cidr_block" {}

variable "vpc_cidr_block" {}

variable "env_prefix" {}

variable "avail_zone" {}

variable "my_ip" {}

variable "instance_type" {}

variable "public_key" {}

# variable "public_key_location" {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id

    tags = {
        Name: "${var.env_prefix}-igw"
    }
}

/* resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }

    tags = {
        Name: "${var.env_prefix}-rt"
    }
}
*/

# resource "aws_route_table_association" "a-rt-subnet" {
#     subnet_id = aws_subnet.myapp-subnet-1.id
#     route_table_id = aws_route_table.myapp-route-table.id
# }

resource "aws_default_route_table" "main-route-table" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }

    tags = {
        Name: "${var.env_prefix}-main-rt"
    }

}

/*
resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress  {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress  {
        from_port = 8080
        to_port =8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port= 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "${var.env_prefix}-sg"
    }
} */

resource "aws_default_security_group" "myapp-default-sg" {
    vpc_id = aws_vpc.myapp-vpc.id

    ingress  {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress  {
        from_port = 8080
        to_port =8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port= 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "${var.env_prefix}-default-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["al2023-ami-*-x86_64"]
    }
    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }
}


resource "aws_key_pair" "ssh-key" {
  key_name = "terraform-key"
  # public_key = file(var.public_key_location)
  public_key = var.public_key
}

resource "aws_instance" "my-app-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_default_security_group.myapp-default-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name


    user_data = file("entry-point.sh")

    tags = {
        Name = "${var.env_prefix}-server"
    }
}

output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2_Ipaddress" {
    value = aws_instance.my-app-server.public_ip
}
