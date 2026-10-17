
#### Choosing the Resource

resource "aws_vpc" "bharadwaj_VPC" {

  # VPC network range.
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "bharadwaj-VPC"
  }
}

##### Creating the AWS Public Subnet

resource "aws_subnet" "public_subnet" {

  # Put this subnet inside our Demo VPC.
  vpc_id = aws_vpc.bharadwaj_VPC.id

  # Subnet network range.
  cidr_block = var.public_subnet_cidr

  # Availability Zone.
  availability_zone = var.public_az

  # Map public IP on launch.
  map_public_ip_on_launch = true
  

  tags = {
    Name = "Public-Subnet"
  }
}

##### Creating the AWS Private Subnet

resource "aws_subnet" "private_subnet" {

  # Put this subnet inside our Demo VPC.
  vpc_id = aws_vpc.bharadwaj_VPC.id

  # Private subnet network range.
  cidr_block = var.private_subnet_cidr

  # Different Availability Zone.
  availability_zone = var.private_az

  tags = {
    Name = "Private-Subnet"
  }
}

##### Creating the IGW

resource "aws_internet_gateway" "igw" {

  # Attach the Internet Gateway to our VPC.
  vpc_id = aws_vpc.bharadwaj_VPC.id

  tags = {
    Name = "Demo-IGW"
  }
}


### Creating the Route Table

resource "aws_route_table" "public_rt" {

  # Create this route table inside our VPC.
  vpc_id = aws_vpc.bharadwaj_VPC.id


  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}


#### Associating the route table to Public Subnet

resource "aws_route_table_association" "public_subnet_association" {

  # Which subnet should use this route table?
  subnet_id = aws_subnet.public_subnet.id

  # Which route table should it use?
  route_table_id = aws_route_table.public_rt.id
}

##### Creating the NAT Gateway Elastic IP

resource "aws_eip" "nat" {

  domain = "vpc"

  tags = {
    Name = "bharadwaj_NAT-EIP"
  }

  # EIP for a NAT Gateway needs the IGW to exist first.
  depends_on = [aws_internet_gateway.igw]
}

##### Creating the NAT Gateway (must live in a public subnet)

resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "bharadwaj_NAT-Gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

### Creating the Private Route Table

resource "aws_route_table" "private_rt" {

  vpc_id = aws_vpc.bharadwaj_VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private-Route-Table"
  }
}

#### Associating the private route table to the Private Subnet

resource "aws_route_table_association" "private_subnet_association" {

  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

#### Creating the security group 

resource "aws_security_group" "public_sg" {

  # Security group name.
  name = "public-sg"

  # Description.
  description = "Security group for public web server"

  # Put the security group inside our VPC.
  vpc_id = aws_vpc.bharadwaj_VPC.id

  # INBOUND RULE - HTTP

  ingress {
    description = "Allow HTTP traffic"

    from_port = 80
    to_port   = 80

    protocol = "tcp"

    # Allow HTTP from anywhere.
    cidr_blocks = ["0.0.0.0/0"]
  }


  # INBOUND RULE - SSH

  ingress {
    description = "Allow SSH"

    from_port = 22
    to_port   = 22

    protocol = "tcp"

    # TEMPORARY FOR LEARNING.
    #
    # In production, restrict this to your public IP.
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public-SG"
  }
}


#### Creating the IAM Role

resource "aws_iam_role" "ec2_role" {

  name = "bharadwaj_EC2-Role"

  # Trust policy.
  #
  # This says:
  # EC2 is allowed to assume this role.
  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = "sts:AssumeRole"

        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "bharadwaj_EC2-Role"
  }
}

#### Attaching the Policy to the instance role 

resource "aws_iam_role_policy_attachment" "s3_read_only" {

  # Attach the policy to our EC2 role.
  role = aws_iam_role.ec2_role.name

  # AWS managed S3 read-only policy.
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

#### Creating the Ec2 Instance Profile

resource "aws_iam_instance_profile" "ec2_profile" {

  name = "bharadwaj_EC2-Profile"

  # Put our IAM role inside the instance profile.
  role = aws_iam_role.ec2_role.name
}


### Creating of Ec2 Instance

resource "aws_instance" "web_server" {

  # Use the Ubuntu AMI discovered by data.tf.
  ami = data.aws_ami.ubuntu.id

  # Instance type comes from terraform.tfvars.
  instance_type = var.instance_type

  # Put EC2 inside our public subnet.
  subnet_id = aws_subnet.public_subnet.id

  # Attach our security group.
  vpc_security_group_ids = [
    aws_security_group.public_sg.id
  ]

  # Attach the IAM instance profile.

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Give the instance a public IPv4 address.
  associate_public_ip_address = true

  tags = {
    Name = "bharadwaj_Web_Server"
  }
}

#### Creating s3 Bucket

resource "aws_s3_bucket" "bharadwaj_s3_bucket" {

  # Bucket name comes from terraform.tfvars.
  bucket = var.s3_bucket_name

  tags = {
      Name        = "bharadwaj_s3_bucket"
    Environment = "Development"
  }
}