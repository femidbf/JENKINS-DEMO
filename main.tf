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
  availability_zone = "eu-west-2a"

  tags = {
    Name = "femi_pub_sn1"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "femi-igw" {
  vpc_id = aws_vpc.femi_vpc.id

  tags = {
    Name = "femi-igw"
  }
}

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

# Associate Public Subnet1 with Public route table
resource "aws_route_table_association" "pub-sub-AS1" {
  subnet_id      = aws_subnet.femi_pub_sn1.id
  route_table_id = aws_route_table.femi-pub-rt.id
}

# # Create Jenkins Security Group
# resource "aws_security_group" "femi-jenkins-sg" {
#   name        = "femi-jenkins-sg"
#   description = "Allow inbound traffic"
#   vpc_id      = aws_vpc.femi_vpc.id

#   ingress {
#     description      = "ssh"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   ingress {
#     description      = "TLC from VPC"
#     from_port        = 8080
#     to_port          = 8080
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "femi-jenkins-sg"
#   }
# }

# # Create Jenkins Server
# resource "aws_instance" "femi_Jenkins_server" {
#   ami           = "ami-035c5dc086849b5de"
#   instance_type = "t2.micro" 
#   vpc_security_group_ids = [aws_security_group.femi-jenkins-sg.id]
#   associate_public_ip_address = true
#   key_name = "femi_key"
#   subnet_id = aws_subnet.femi_pub_sn1.id
#   user_data = <<-EOF
# #!/bin/bash
# sudo yum update -y
# sudo yum install wget -y
# sudo yum install git -y
# sudo yum install maven -y
# sudo wget http://get.jenkins.io/redhat/jenkins-2.346-1.1.noarch.rpm
# sudo rpm -ivh jenkins-2.346-1.1.noarch.rpm
# sudo yum upgrade -y
# sudo yum install jenkins java-11-openjdk-devel -y --nobest
# sudo yum install epel-release java-11-openjdk-devel
# sudo systemctl daemon-reload
# sudo systemctl start jenkins
# sudo systemctl enable jenkins
# sudo hostnamectl set-hostname Jenkins
#   EOF
#   tags = {
#     Name = "femi_Jenkins_server"
#   }
# }

# Create Keypair Servers
resource "aws_key_pair" "femi_key" {
  key_name   = "femi_key"
  public_key = file(var.femi_key)
}

# Create Ansible Security Group
resource "aws_security_group" "femi1-Ansible-sg" {
  name        = "femi1-Ansible-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.femi_vpc.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
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
    Name = "femi1-Ansible-sg"
  }
}

# Create Ansible Server
resource "aws_instance" "femi1_Ansible_server" {
  ami           = "ami-035c5dc086849b5de"
  instance_type = "t2.micro" 
  vpc_security_group_ids = [aws_security_group.femi1-Ansible-sg.id]
  associate_public_ip_address = true
  key_name = "femi_key"
  subnet_id = aws_subnet.femi_pub_sn1.id
  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install python3 pyhton3-pip -y
sudo alternatives --set python /usr/bin/pythons
sudo yum install ansible -y
sudo hostnamectl set-hostname Ansible
  EOF
  tags = {
    Name = "femi_Ansible_server"
  }
}

# Create Hostserver Security Group
resource "aws_security_group" "femi1-Hostserver-sg" {
  name        = "femi1-Hostserver-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.femi_vpc.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 ingress {
    description      = "TLC from VPC"
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
    Name = "femi1-Hostserver-sg"
  }
}

# Create HostServer
resource "aws_instance" "femi1_Hostserver" {
  ami           = "ami-035c5dc086849b5de"
  instance_type = "t2.micro" 
  vpc_security_group_ids = [aws_security_group.femi1-Hostserver-sg.id]
  associate_public_ip_address = true
  key_name = "femi_key"
  subnet_id = aws_subnet.femi_pub_sn1.id
  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
  EOF
  
  tags = {
    Name = "femi1_Hostserver"
  }
}