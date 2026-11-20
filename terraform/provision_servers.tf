# Dynamically fetch the latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# Create an elastic IP for the ec2 instance
resource "aws_eip" "fitbyte" {
  domain   = "vpc"
  instance = aws_instance.fitbyte_server.id

  depends_on = [aws_internet_gateway.fitbyte_igw]

  tags = {
    Name = "fitbyte"
  }
}

output "fitbyte_public_ip" {
  value = aws_eip.fitbyte.public_ip
}

# Create EC2 Server
resource "aws_instance" "fitbyte_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.fitbyte_public_a.id
  vpc_security_group_ids = [aws_security_group.fitbyte_ec2_sg.id]
  key_name               = "sample_key"

  tags = {
    Name = "fitbyte_server"
  }
}

# Create RDS
resource "aws_db_instance" "postgres" {
  identifier        = "project-postgres"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_subnet_group_name   = aws_db_subnet_group.fitbyte_db.name
  vpc_security_group_ids = [aws_security_group.fitbyte_rds.id]

  publicly_accessible = false

  username                    = "dbadmin"
  manage_master_user_password = true

  skip_final_snapshot = true
}