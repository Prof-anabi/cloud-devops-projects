# Output the First VPC ID
output "first_vpc_id" {
  description = "The ID of the First VPC"
  value       = aws_vpc.first_vpc.id
}

# Output the Second VPC ID
output "second_vpc_id" {
  description = "The ID of the Second VPC"
  value       = aws_vpc.second_vpc.id
}

# Output the Public Subnet ID in the First VPC
output "public_subnet_first_vpc_id" {
  description = "The ID of the public subnet in the First VPC"
  value       = aws_subnet.public_subnet_first_vpc.id
}

# Output the Private Subnet ID in the Second VPC
output "private_subnet_second_vpc_id" {
  description = "The ID of the private subnet in the Second VPC"
  value       = aws_subnet.private_subnet_second_vpc.id
}

# Output the Internet Gateway ID
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway for the First VPC"
  value       = aws_internet_gateway.igw.id
}

# Output the Route Table ID
output "public_route_table_id" {
  description = "The ID of the public route table for the First VPC"
  value       = aws_route_table.public_rt.id
}

# Output the Security Group ID for Public EC2 instance
output "public_ec2_sg_id" {
  description = "The ID of the Security Group for the public EC2 instance"
  value       = aws_security_group.ec2sg.id
}

# Output the Security Group ID for Private EC2 instance
output "private_ec2_sg_id" {
  description = "The ID of the Security Group for the private EC2 instance"
  value       = aws_security_group.privateec2sg.id
}

# Output the Public EC2 Instance ID
output "public_ec2_instance_id" {
  description = "The ID of the public EC2 instance"
  value       = aws_instance.first_vpc_ec2.id
}

# Output the Public EC2 Instance Public IP
output "public_ec2_instance_public_ip" {
  description = "The Public IP address of the public EC2 instance"
  value       = aws_instance.first_vpc_ec2.public_ip
}

# Output the Private EC2 Instance ID
output "private_ec2_instance_id" {
  description = "The ID of the private EC2 instance"
  value       = aws_instance.second_vpc_ec2.id
}

# Output the Transit Gateway ID
output "transit_gateway_id" {
  description = "The ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.demo_tg.id
}

# Output the Transit Gateway Attachment ID for the First VPC
output "transit_gateway_attachment_first_vpc_id" {
  description = "The ID of the Transit Gateway attachment for the First VPC"
  value       = aws_ec2_transit_gateway_vpc_attachment.first_vpc_tga.id
}

# Output the Transit Gateway Attachment ID for the Second VPC
output "transit_gateway_attachment_second_vpc_id" {
  description = "The ID of the Transit Gateway attachment for the Second VPC"
  value       = aws_ec2_transit_gateway_vpc_attachment.second_vpc_tga.id
}