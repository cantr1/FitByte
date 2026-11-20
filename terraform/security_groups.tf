
# Create SG for RDS
resource "aws_security_group" "fitbyte_rds" {
  name        = "rds-sg"
  description = "Allow PostgreSQL from EC2"
  vpc_id      = aws_vpc.fitbyte_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.fitbyte_ec2_sg.id]
  }

  tags = {
    Name = "rds-sg"
  }
}


# Create SG for Server & Define Rules
resource "aws_security_group" "fitbyte_ec2_sg" {
  name_prefix = "web-access-"
  description = "HTTP from anywhere, SSH from my public IP"
  vpc_id      = aws_vpc.fitbyte_vpc.id

  tags = {
    Name = "fitbyte_ec2_sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# === EC2 Rules Ingress Rules ===
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.fitbyte_ec2_sg.id
  description       = "HTTP from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.fitbyte_ec2_sg.id
  description       = "HTTPs from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.fitbyte_ec2_sg.id
  description       = "SSH from trusted IP"
  cidr_ipv4         = "203.0.113.10/32" #SAMPLE VALUE - Change to actual IP
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# === EC2 Egress Rules ===
resource "aws_vpc_security_group_egress_rule" "allow_http" {
  security_group_id = aws_security_group.fitbyte_ec2_sg.id
  description       = "HTTP from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_https" {
  security_group_id = aws_security_group.fitbyte_ec2_sg.id
  description       = "HTTPs from anywhere"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_psql" {
  security_group_id            = aws_security_group.fitbyte_ec2_sg.id
  referenced_security_group_id = aws_security_group.fitbyte_rds.id
  description                  = "Ingress from RDS"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}