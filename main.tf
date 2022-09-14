## How to read terraform (.tf)
#
# Configurations are set via the resource struct:
#   `resource <type> <local-name> { fields }`
#
# Types are defined by the provider (AWS in this case).
#   Ref https://registry.terraform.io/providers/hashicorp/aws/latest/docs
#
# Terraform files in one directory are considered one module. Names and
# variables in different files are shared.
#
## File layout
#
# - main.tf: network, misc cluster modules, bastion, load-balance
# - nodes.tf: tidb, pd, tikv.
# - variables.tf: public variables
# - *.yml: commands to initialize certain nodes
# - topology.yaml: a minimum TiUP topology file
#
# Most of the time you will only need to read and modify "nodes.tf" and
# "variables.tf".
#
## Other notes
#
# - Cross-AZ network flow is rather expensive. You should use single-AZ
#   topology if cross-AZ is not a concern. To do that, modify `subnet_id`
#   and `private_ip` in "nodes.tf".
#

provider "aws" {
  profile = "storage"
  # must not change
  region  = var.region
}

resource "tls_private_key" "tikv_cross_az_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.name
  public_key = tls_private_key.tikv_cross_az_key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.tikv_cross_az_key.private_key_pem}' > ./${var.name}.pem"
  }
}

resource "aws_vpc" "cross_az_test_client" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.name
    usedby = var.name
  }
}

resource "aws_subnet" "test_subnet" {
  vpc_id            = aws_vpc.cross_az_test_client.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = var.name
    usedby = var.name
  }
}
resource "aws_internet_gateway" "cross_az_test_client" {
  vpc_id = aws_vpc.cross_az_test_client.id

  tags = {
    Name = var.name
    usedby = var.name
  }
}

resource "aws_route_table" "public_rt_client" {
  vpc_id = aws_vpc.cross_az_test_client.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cross_az_test_client.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.cross_az_test_client.id
  }

  tags = {
    Name = var.name
    usedby = var.name
  }
}

resource "aws_route_table_association" "public_rt_client" {
  subnet_id      = aws_subnet.test_subnet.id
  route_table_id = aws_route_table.public_rt_client.id
}

resource "aws_security_group" "test_client_sg" {
  name   = "test client"
  vpc_id = aws_vpc.cross_az_test_client.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "128.1.49.85/32",
      "45.251.23.186/32",
      "45.251.23.187/32",
      "45.251.23.188/32",
      "45.251.23.189/32",
      "45.251.23.190/32",
      "45.251.23.191/32",
      "180.167.192.138/32",
      "211.95.24.10/32",
      "211.95.24.11/32",
      "211.95.24.12/32",
      "211.95.24.13/32",
      "211.95.24.14/32",
      "211.95.24.15/32",
      "118.113.15.98/32",
      "101.207.139.187/32",
      "183.129.144.202/32",
      "183.129.144.207/32",
      "183.129.144.203/32",
      "183.129.144.204/32",
      "183.129.144.205/32",
      "183.129.144.206/32",
      "39.170.92.156/32",
      "183.6.107.178/32",
      "119.136.31.176/32",
      "117.50.84.111/32",
      "106.75.96.68/32",
      "106.75.54.70/32",
      "106.75.116.22/32",
      "120.92.102.252/32",
      "120.92.76.253/32",
      "128.1.49.135/32",
      "106.75.52.157/32",
      "118.194.230.143/32",
      "106.75.53.135/32",
      "203.90.236.205/32",
      "40.74.68.232/32",
      "117.50.66.239/32",
      "118.113.15.98/32",
      "3.1.29.171/32",
      "18.142.58.124/32"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "bastion_data" {
  template = file("bastion.yml")
}

data "template_file" "user_data" {
  template = file("server.yml")
}

resource "aws_vpc" "cross_az_test" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.name
    usedby = var.name
  }
}

resource "aws_subnet" "subnet_0" {
  vpc_id            = aws_vpc.cross_az_test.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.name}-subnet-0"
    usedby = var.name
  }
}

resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.cross_az_test.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.name}-subnet-1"
    usedby = var.name
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = aws_vpc.cross_az_test.id
  cidr_block        = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.region}c"

  tags = {
    Name = "${var.name}-subnet-2"
    usedby = var.name
  }
}

resource "aws_internet_gateway" "cross_az_test" {
  vpc_id = aws_vpc.cross_az_test.id

  tags = {
    Name = "${var.name}-cross-az-zlib"
    usedby = var.name
  }
}

resource "aws_eip" "subnet_nat_0_public_ip" {
  vpc      = true
}

resource "aws_nat_gateway" "subnet_nat_0" {
  allocation_id = aws_eip.subnet_nat_0_public_ip.id
  subnet_id     = aws_subnet.subnet_0.id

  tags = {
    Name = "${var.name}-nat"
  }

  depends_on = [aws_internet_gateway.cross_az_test]
}

resource "aws_eip" "subnet_nat_1_public_ip" {
  vpc      = true
}

resource "aws_nat_gateway" "subnet_nat_1" {
  allocation_id = aws_eip.subnet_nat_1_public_ip.id
  subnet_id     = aws_subnet.subnet_1.id

  tags = {
    Name = "${var.name}-nat"
  }

  depends_on = [aws_internet_gateway.cross_az_test]
}

resource "aws_eip" "subnet_nat_2_public_ip" {
  vpc      = true
}

resource "aws_nat_gateway" "subnet_nat_2" {
  allocation_id = aws_eip.subnet_nat_2_public_ip.id
  subnet_id     = aws_subnet.subnet_1.id

  tags = {
    Name = "${var.name}-nat"
  }

  depends_on = [aws_internet_gateway.cross_az_test]
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.cross_az_test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cross_az_test.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.cross_az_test.id
  }

  tags = {
    Name = "${var.name}-cross-az-zlib"
    usedby = var.name
  }
}

resource "aws_route_table_association" "public_1_rt" {
  subnet_id      = aws_subnet.subnet_0.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2_rt" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_3_rt" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "bastion_sg" {
  name   = "bastion security groups"
  vpc_id = aws_vpc.cross_az_test.id

  ingress {
    from_port = 3000
    protocol  = "tcp"
    to_port   = 3000
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "128.1.49.85/32",
      "45.251.23.186/32",
      "45.251.23.187/32",
      "45.251.23.188/32",
      "45.251.23.189/32",
      "45.251.23.190/32",
      "45.251.23.191/32",
      "180.167.192.138/32",
      "211.95.24.10/32",
      "211.95.24.11/32",
      "211.95.24.12/32",
      "211.95.24.13/32",
      "211.95.24.14/32",
      "211.95.24.15/32",
      "118.113.15.98/32",
      "101.207.139.187/32",
      "183.129.144.202/32",
      "183.129.144.207/32",
      "183.129.144.203/32",
      "183.129.144.204/32",
      "183.129.144.205/32",
      "183.129.144.206/32",
      "39.170.92.156/32",
      "183.6.107.178/32",
      "119.136.31.176/32",
      "117.50.84.111/32",
      "106.75.96.68/32",
      "106.75.54.70/32",
      "106.75.116.22/32",
      "120.92.102.252/32",
      "120.92.76.253/32",
      "128.1.49.135/32",
      "106.75.52.157/32",
      "118.194.230.143/32",
      "106.75.53.135/32",
      "203.90.236.205/32",
      "40.74.68.232/32",
      "117.50.66.239/32",
      "118.113.15.98/32",
      "10.0.0.0/16",
      "3.1.29.171/32",
      "18.142.58.124/32"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "safety_sg" {
  name   = "inner sg"
  vpc_id = aws_vpc.cross_az_test.id

  ingress {
    from_port = 3000
    protocol  = "tcp"
    to_port   = 3000
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [
      "128.1.49.85/32",
      "45.251.23.186/32",
      "45.251.23.187/32",
      "45.251.23.188/32",
      "45.251.23.189/32",
      "45.251.23.190/32",
      "45.251.23.191/32",
      "180.167.192.138/32",
      "211.95.24.10/32",
      "211.95.24.11/32",
      "211.95.24.12/32",
      "211.95.24.13/32",
      "211.95.24.14/32",
      "211.95.24.15/32",
      "118.113.15.98/32",
      "101.207.139.187/32",
      "183.129.144.202/32",
      "183.129.144.207/32",
      "183.129.144.203/32",
      "183.129.144.204/32",
      "183.129.144.205/32",
      "183.129.144.206/32",
      "39.170.92.156/32",
      "183.6.107.178/32",
      "119.136.31.176/32",
      "117.50.84.111/32",
      "106.75.96.68/32",
      "106.75.54.70/32",
      "106.75.116.22/32",
      "120.92.102.252/32",
      "120.92.76.253/32",
      "128.1.49.135/32",
      "106.75.52.157/32",
      "118.194.230.143/32",
      "106.75.53.135/32",
      "203.90.236.205/32",
      "40.74.68.232/32",
      "117.50.66.239/32",
      "118.113.15.98/32",
      "10.0.0.0/16",
      "3.1.29.171/32",
      "18.142.58.124/32"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "grafana_sg" {
  name   = "grafana sg"
  vpc_id = aws_vpc.cross_az_test.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "prometheus" {
  ami           = var.amis_x86
  instance_type = var.tools_instance_type
  key_name      = aws_key_pair.generated_key.key_name
  private_ip = "10.0.1.15"

  subnet_id                   = aws_subnet.subnet_0.id
  vpc_security_group_ids      = [aws_security_group.safety_sg.id]

  user_data = data.template_file.user_data.rendered

  root_block_device {
    delete_on_termination = true
    volume_size           = 25
    volume_type           = "gp3"
  }

  tags = {
    Name = "${var.name}-prometheus"
    usedby = var.name
    component = "${var.name}-prometheus"
  }
}

resource "aws_instance" "grafana" {
  ami           = var.amis_x86
  instance_type = var.tools_instance_type
  key_name      = aws_key_pair.generated_key.key_name

  private_ip = "10.0.1.16"

  subnet_id                   = aws_subnet.subnet_0.id
  vpc_security_group_ids      = [aws_security_group.safety_sg.id, aws_security_group.grafana_sg.id ]
  user_data = data.template_file.user_data.rendered

  root_block_device {
    delete_on_termination = true
    volume_size           = 25
    volume_type           = "gp3"
  }

  tags = {
    Name = "${var.name}-grafana"
    usedby = var.name
    component = "${var.name}-grafana"
  }
}

resource "aws_eip" "grafana_public_ip" {
  instance = aws_instance.grafana.id
  vpc      = true
}


resource "aws_instance" "bastion" {
  ami           = var.amis_x86
  instance_type = var.tools_instance_type
  key_name      = aws_key_pair.generated_key.key_name

  private_ip = "10.0.1.17"

  subnet_id                   = aws_subnet.subnet_0.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

  user_data = data.template_file.bastion_data.rendered

  ebs_block_device {
    device_name = "/dev/xvdh"
    delete_on_termination = true
    volume_size = var.bastion_storage_size
    volume_type = "gp3"
    tags = {
      Name = "${var.name}-bastion"
      usedby = var.name
      component = "${var.name}-bastion"
    }
  }
  root_block_device {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp3"
  }

  tags = {
    Name = "${var.name}-bastion"
    usedby = var.name
    component = "${var.name}-bastion"
  }
}


resource "aws_eip" "cross_az_bastion_public_ip" {
  instance = aws_instance.bastion.id
  vpc      = true
}

resource "aws_lb" "tidb_cross_az_public" {
  name               = var.name
  load_balancer_type = "network"
  internal           = false
  enable_cross_zone_load_balancing = true
  subnets = [  aws_subnet.subnet_0.id, aws_subnet.subnet_1.id, aws_subnet.subnet_2.id ]
}

resource "aws_lb_target_group" "tidb_cross_az_public" {
  name     = var.name
  port     = 4000
  protocol = "TCP"
  vpc_id      = aws_vpc.cross_az_test.id

  depends_on = [
    aws_lb.tidb_cross_az_public
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "tidb_cross_az_public" {

  load_balancer_arn = aws_lb.tidb_cross_az_public.arn

  protocol = "TCP"
  port     = 4000

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tidb_cross_az_public.arn
  }
}

output "prometheus" {
  description = "prometheus ip"
  value       = aws_instance.prometheus.private_ip
}

output "grafana" {
  description = "grafana ip"
  value       = aws_instance.grafana.private_ip
}

output "grafana_public_ip" {
  description = "grafana public ip"
  value       = aws_eip.grafana_public_ip.public_ip
}

output "bastion_public_ip" {
  description = "bastion ip"
  value       = aws_eip.cross_az_bastion_public_ip.public_ip
}

output "tidb_public_url" {
  description = "tidb public url"
  value       = format("mysql -h ${aws_lb.tidb_cross_az_public.dns_name} -P4000 -p")
}

output "ssh_bastion_server" {
  description = "ssh into bastion server"
  value       = format("ssh -i ${var.name}.pem centos@${aws_eip.cross_az_bastion_public_ip.public_ip}")
}
