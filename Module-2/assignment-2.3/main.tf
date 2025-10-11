resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.public.id 
  associate_public_ip_address = true
  key_name                    = "vimal-key-pair" #Change to your keyname, e.g. jazeel-key-pair
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
 
  tags = {
   Name = "${var.name}-ec2"
 }

}

resource "aws_security_group" "allow_ssh" {
  name        = "" #Security group name, e.g. jazeel-terraform-security-group
  description = "Allow SSH inbound"
  vpc_id      = data.aws_vpc.selected.id  #VPC ID (Same VPC as your EC2 subnet above), E.g. vpc-xxxxxxx
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"  
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

