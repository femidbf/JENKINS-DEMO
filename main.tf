# Create VPC
resource "aws_vpc" "femi_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "femi_vpc"
  }
}

# Create Public Subnet1
resource "aws_subnet" "femi_pub_sn1" {
  vpc_id            = aws_vpc.femi_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "femi_pub_sn1"
  }
}

# Create Public Subnet2
resource "aws_subnet" "femi_pub_sn2" {
  vpc_id            = aws_vpc.femi_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "femi_pub_sn2"
  }
}

# Create Private Subnet1
resource "aws_subnet" "femi_prv_sn1" {
  vpc_id            = aws_vpc.femi_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "femi_prv_sn1"
  }
}

# Create Private Subnet2
resource "aws_subnet" "femi_prv_sn2" {
  vpc_id            = aws_vpc.femi_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "femi_prv_sn2"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "femi-igw" {
  vpc_id = aws_vpc.femi_vpc.id

  tags = {
    Name = "femi-igw"
  }
}

# # Create NAT_Gateway
# resource "aws_nat_gateway" "femi-ngw" {
#   allocation_id = aws_eip.femi-eip.id
#   subnet_id     = aws_subnet.femi_pub_sn1.id

#   tags = {
#     Name = "femi-ngw"
#   }
# }

# # Create Elastic IP
# resource "aws_eip" "femi-ngw" {
#   depends_on = [aws_internet_gateway.femi-igw]
# }

# Create Public Route table
resource "aws_route_table" "femi-pub-rt" {
  vpc_id = aws_vpc.femi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.femi-igw.id
  }

  tags = {
    Name = "femi-pub-rt"
  }
}

# Create Private Route table
resource "aws_route_table" "femi-prv-rt" {
  vpc_id = aws_vpc.femi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.femi-ngw.id
  }

  tags = {
    Name = "femi-prv-rt"
  }
}

# Associate Public Subnet1 with Public route table
resource "aws_route_table_association" "pub-sub-AS1" {
  subnet_id      = aws_subnet.femi_pub_sn1.id
  route_table_id = aws_route_table.femi-pub-rt.id
}

# Associate Public Subnet2 with Public route table
resource "aws_route_table_association" "pub-sub-AS2" {
  subnet_id      = aws_subnet.femi_pub_sn2.id
  route_table_id = aws_route_table.femi-pub-rt.id
}

# Associate Private Subnet1 with Private route table
resource "aws_route_table_association" "prv-sub-AS1" {
  subnet_id      = aws_subnet.femi_prv_sn1.id
  route_table_id = aws_route_table.femi-prv-rt.id
}

# Associate Private Subnet2 with Private route table
resource "aws_route_table_association" "prv-sub-AS2" {
  subnet_id      = aws_subnet.femi_prv_sn2.id
  route_table_id = aws_route_table.femi-prv-rt.id
}

# Create FrontEnd Security Group
resource "aws_security_group" "femi-frontend-sg" {
  name        = "femi-frontend-sg"
  description = "Allow ssh and http traffic"
  vpc_id      = aws_vpc.femi_vpc.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "femi-frontend-sg"
  }
}

# Create BackEnd Security Group
resource "aws_security_group" "femi-backend-sg" {
  name        = "femi-backend-sg"
  description = "Allow MySql and ssh traffic"
  vpc_id      = aws_vpc.femi_vpc.id

  ingress {
    description      = "MySql"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["10.0.1.0/24", "10.0.2.0/24"]
  }

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.0.1.0/24", "10.0.2.0/24"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "femi-frontend-sg"
  }
}

# # Create Database subnet group
# resource "aws_db_subnet_group" "femi-db-sg" {
#   name       = "femi-db-sg"
#   subnet_ids = [aws_subnet.femi_prv_sn1.id, aws_subnet.femi_prv_sn2.id]

#   tags = {
#     Name = "femi-db-sg"
#   }
# }

# # Create MySql RDS
# resource "aws_db_instance" "femi-db" {
#   identifier = "femi-database"
#   allocated_storage    = 20
#   engine               = "mysql"
#   engine_version       = "8.0"
#   instance_class       = "db.t2.micro"
#   db_name                 = "femi-db"
#   username             = "femi"
#   password             = "Femi123"
#   multi_az = true
#   parameter_group_name = "default.mysql8.0"
#   deletion_protection = false  
#   skip_final_snapshot  = true
#   db_subnet_group_name = aws_db_subnet_group.femi-db-sg.name
#   vpc_security_group_ids = [aws_security_group.femi-backend-sg.id]
# }

# # Create s3 Media Bucket
# resource "aws_s3_bucket" "femi-media-buck" {
#   bucket = "femi-media-buck"

#   tags = {
#     Name        = "femi-media-buck"
#     Environment = "Dev"
#   }
# }

# # Create s3 Media Bucket Policy
# resource "aws_s3control_bucket_policy" "femi-media-buck-policy" {
#   bucket = aws_s3control_bucket.femi-media-buck.arn
#   policy = jsonencode({
#     Id = "mediaBucketPolicy"
#     Statement = [
#       {
#         Action = ["s3:GetObject","s3:GetObjectVersion"]
#         Effect = "Allow"
#         Principal = {
#           AWS = "*"
#         }
#         Resource = "arn:aws:s3:::femi-media-buck/*"
#         Sid      = "PublicReadGetObject"
#       }
#     ]
#     Version = "2012-10-17"
#   })
# }

# # Craete s3 Buckcet-Backup (code buceket)
# resource "aws_s3_bucket" "femi-code-buck" {
#   bucket = "femi-code-buck"
#   force_destroy = true

#   tags = {
#     Name        = "femi-code-buck"
#     Environment = "Dev"
#   }
# }

# # Create s3 Bucket for Media access logs
# resource "aws_s3_bucket" "femi-medialogs-buck" {
#   bucket = "femi-medialogs-buck"
#   force_destroy = true

#   tags = {
#     Name        = "femi-medialogs-buck"
#     Environment = "Dev"
#   }
# }

# # Create s3 Media access logs Bucket Policy
# resource "aws_s3control_bucket_policy" "femi-medialogs-buck-policy" {
#   bucket = aws_s3control_bucket.femi-medialogs-buck.arn
#   policy = jsonencode({
#     Id = "medialogsBucketPolicy"
#     Statement = [
#       {
#         Action = ["s3:GetObject"]
#         Effect = "Allow"
#         Principal = {
#           AWS = "*"
#         }
#         Resource = "arn:aws:s3:::femi-medialogs-buck/*"
#         Sid      = "PublicReadGetObject"
#       }
#     ]
#     Version = "2012-10-17"
#   })
# }
# data "aws_db_instance" "femi-db" {
#   db_instance_identifier = "femi-database"
#   depends_on = [aws_db_instance.femi-db]
# }

# # Create IAM role w/ S3 full permission for EC2
# resource "aws_iam_instance_profile" "femi-iam-profile" {
#   name = "femi-iam-profile"
#   role = aws_iam_role.femi-iam-role.name
# }
# resource "aws_iam_role" "femi-iam-role" {
#   name = "femi-iam-role"
#   description = "S3 Full Permsision"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# # Create IAM Role policy attachment
# resource "aws_iam_role_policy_attachment" "femi-iam-role-pol-attch" {
#   role       = aws_iam_role.femi-iam-role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
# }

# Create EC2 instance
resource "aws_instance" "femi_webserver" {
  ami           = "0f0f1c02e5e4d9d9f"
  instance_type = "t2.micro" 
  iam_instance_profile = aws_iam_instance_profile.femi-iam-profile.id
  vpc_security_group_ids = [aws_security_group.femi-frontend-sg]
  associate_public_ip_address = true
  key_name = "femi_key"
  subnet_id = aws_subnet.femi_pub_sn1.id
  user_data = <<EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum upgrade -y


  tags = {
    Name = "femi_webserver"
  }
}

# Create Route 53 custom Domain name
