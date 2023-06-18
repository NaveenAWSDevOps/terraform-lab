provider "aws" {
  
  region = "ap-south-1"
#   access_key = "AKIAWPKEV2QCWWHILPDP"
#   secret_key = "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"

} 

variable "subnet_cidr_block"  {
  description = "subnet cidr block"
  default = "10.0.10.0/24 "
}

variable "vpc_cidr_block"  {
  description = "subnet cidr block"
  type = string
}

variable "environment"  {
  description = "type of environment"
  
}

variable avail_zone {}

resource "aws_vpc" "development-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: var.environment
    }
}



resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.development-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "development-subnet-1"
        
    }
}

data "aws_vpc" "existing-vpc" {
    id = "vpc-073e2b47be0198018"
}

resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing-vpc.id
    cidr_block = "172.31.48.0/20"
    availability_zone = "ap-south-1a"
    tags = {
        Name: "default-subnet-2"
    }
}

output "dev-vpc-id" {
    value = aws_vpc.development-vpc.id
}

output "dev-subnet-1" {
    value = aws_subnet.dev-subnet-1.id
}