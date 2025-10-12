provider "aws" {
  region = var.region
}

# -------------------------------
# 1️ VPC
# -------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

# -------------------------------
# 2 Public Subnets in Different AZs
# -------------------------------
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-subnet"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-subnet"
  }
}

# -------------------------------
# 3 Private Subnets in Different AZs
# -------------------------------
resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}-private-subnet-a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}-private-subnet-b"
  }
}

# -------------------------------
# 4 Internet Gateway + Route Table for Public Subnet
# -------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}


# -------------------------------
# 5 Security Group for RDS
# -------------------------------
resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-rds-sg"
  description = "Security group for RDS MySQL"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-rds-sg"
  }
}

# -------------------------------
# 6 DB Subnet Group (Private)
# -------------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.name}-rds-subnet-group"
  description = "Subnet group for RDS in private subnets"
  subnet_ids  = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]

  tags = {
    Name = "${var.name}-rds-subnet-group"
  }
}

# -------------------------------
# 7 Store Credentials in Secrets Manager
# -------------------------------
resource "aws_secretsmanager_secret" "rds_secret" {
  name = "${var.name}-rds-credentials"
}

resource "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = var.db_password
  })
}

# -------------------------------
# 8 RDS MySQL Instance
# -------------------------------
resource "aws_db_instance" "mysql" {
  identifier              = "${var.name}-database"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  storage_type            = "gp2"
  username                = jsondecode(aws_secretsmanager_secret_version.rds_secret_value.secret_string)["username"]
  password                = jsondecode(aws_secretsmanager_secret_version.rds_secret_value.secret_string)["password"]

  tags = {
    Name = "${var.name}-database"
  }
}

#############################
# 9 DynamoDB Table
#############################
resource "aws_dynamodb_table" "book_inventory" {
  name         = "${var.name}-bookinventory"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ISBN"
  range_key    = "Genre"

  attribute { 
    name = "ISBN"
    type = "S" 
  }
  attribute {
    name = "Genre"
    type = "S" 
  }

  tags = { 
    Name = "${var.name}-bookinventory"
  }
}
# #############################
# 10 Bastion EC2 Host
#############################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter { 
    name = "name"
    values = ["al2023-ami-*-x86_64"] 
  }
}

resource "aws_security_group" "bastion_sg" {
  name   = "${var.name}-bastion-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-bastion-sg" }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.name}-bastion-key"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = aws_key_pair.bastion_key.key_name
  associate_public_ip_address = true

  tags = { Name = "${var.name}-bastion-ec2" }
}