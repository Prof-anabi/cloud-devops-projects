provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create first VPC 
resource "aws_vpc" "first_vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "First_VPC"
  }
}

# Create public subnet for first vpc
resource "aws_subnet" "public_subnet_first_vpc" {
  vpc_id            = aws_vpc.first_vpc.id
  cidr_block        = "10.0.0.0/25"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public_subnet_first_VPC"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.first_vpc.id
  tags = {
    Name = "IGW"
  }
}
# Create Public Route table and attach to internet gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.first_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PublicRT"
  }
}
# Associate Public subnet table with public route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet_first_vpc.id
  route_table_id = aws_route_table.public_rt.id
}

# Create Security group for EC2
resource "aws_security_group" "ec2sg" {
  name        = "whiz_sg"
  description = "whizlabssecuritygroup"
  vpc_id      = aws_vpc.first_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "whiz_sg"
  }
}

# Create first VPC for EC2 
resource "aws_instance" "first_vpc_ec2" {
  ami                         = "ami-0b09ffb6d8b58ca91"
  instance_type               = "t2.micro"
  key_name                    = "MySSHKey" # Make sure you use the same Key pair that you created earlier
  vpc_security_group_ids      = ["${aws_security_group.ec2sg.id}"]
  subnet_id                   = aws_subnet.public_subnet_first_vpc.id
  iam_instance_profile        = "ContainerInstanceEC2Role"
  associate_public_ip_address = true
  user_data                   = <<-EOF
#!/bin/bash
sudo su
dnf update -y
dnf install httpd -y
systemctl start httpd
systemctl enable httpd
echo "<html><h1> Welcome to Whizlabs Public Server</h1><html>" >
/var/www/html/index.html
EOF
  tags = {
    Name = "First_VPCs_EC2"
  }
}

# Create Second VPC
resource "aws_vpc" "second_vpc" {
  cidr_block           = "20.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Second_VPC"
  }
}

# Create private subnet for second vpc
resource "aws_subnet" "private_subnet_second_vpc" {
  vpc_id            = aws_vpc.second_vpc.id
  cidr_block        = "20.0.0.0/25"
  availability_zone = "us-east-1a"
}

# Create second Security group for EC2
resource "aws_security_group" "privateec2sg" {
  name        = "whiz_sg2"
  description = "whizlabssecuritygroup"
  vpc_id      = aws_vpc.second_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "whiz_sg"
  }
}

#create second instance in second vpc

resource "aws_instance" "second_vpc_ec2" {
  ami                         = "ami-0b09ffb6d8b58ca91"
  instance_type               = "t2.micro"
  key_name                    = "MySSHKey"
  vpc_security_group_ids      = ["${aws_security_group.privateec2sg.id}"]
  subnet_id                   = aws_subnet.private_subnet_second_vpc.id
  associate_public_ip_address = false

  user_data = <<-EOF
        #!/bin/bash
        sudo su
        dnf update -y
        dnf install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "<html><h1> Welcome to Whizlabs Private Server</h1><html>" > /var/www/html/index.html
        EOF

  tags = {
    Name = "Second_VPCs_EC2"
  }
}


#create a transit gateway
resource "aws_ec2_transit_gateway" "demo_tg" {
  description = "TG for peering two VPCs"
  tags = {
    Name = "DemoTG"
  }
}

# create transit gateway attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "first_vpc_tga" {
  transit_gateway_id = aws_ec2_transit_gateway.demo_tg.id
  vpc_id             = aws_vpc.first_vpc.id
  subnet_ids         = [aws_subnet.public_subnet_first_vpc.id]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "second_vpc_tga" {
  transit_gateway_id = aws_ec2_transit_gateway.demo_tg.id
  vpc_id             = aws_vpc.second_vpc.id
  subnet_ids         = [aws_subnet.private_subnet_second_vpc.id]
}

# add routes to the route tables of both VPCs to enable communication between them
resource "aws_route" "first_vpc_route_to_second_vpc" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = aws_vpc.second_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.demo_tg.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.second_vpc_tga]
}

resource "aws_route" "second_vpc_route_to_first_vpc" {
  route_table_id         = aws_vpc.second_vpc.main_route_table_id
  destination_cidr_block = aws_vpc.first_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.demo_tg.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.first_vpc_tga]
}

