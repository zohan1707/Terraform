terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.22.0"
    }
  }
}

provider "aws" {

}


resource "aws_key_pair" "key" {
  key_name =  "key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "key" {
  content = tls_private_key.rsa.private_key_pem
  filename = "key.pem"
  file_permission = 400
}

resource "aws_security_group" "connection" {
    name = "public connect"

    ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    }

    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_instance" "instance_name" {
    ami = "ami-02fe204d17e0189fb"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.connection.id]

    key_name = aws_key_pair.key.key_name
    
    tags = {
      Name = "instance1"
    }
    }


