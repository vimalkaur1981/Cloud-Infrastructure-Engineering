data "aws_vpc" "selected" {
 filter {
   name   = "tag:Name"
   values = ["vimal-vpc"] # to be replaced with your VPC name
 }
}
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
data "aws_vpc" "default_vpc" {
  filter {
    name   = "tag:Name"
    values = ["vimal-vpc"]  # matches your VPC
  }
}

# Get all subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

# Get details for the first subnet (public one)
data "aws_subnet" "public" {
  id = tolist(data.aws_subnets.default.ids)[0]
}