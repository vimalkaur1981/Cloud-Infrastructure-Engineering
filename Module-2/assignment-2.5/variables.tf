variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Base name for resources (e.g., vimal)"
  type        = string
  default     = "vimal"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "Admin12345!"
}

variable "my_ip" { 
  default = "122.11.212.85/32" 
} 
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "/home/vimalkaur/.ssh/id_rsa.pub"   # Replace with your OS path
}