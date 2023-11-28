provider "aws" {
  region = "${var.region}"
}

//NETWORK
resource "aws_vpc" "vpc-project1" {
  cidr_block = "${var.vpc_cidr_block}" 
  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_subnet" "public-subnets-project1" {
  vpc_id                  = aws_vpc.vpc-project1.id
  for_each                = toset(var.availability_zones)
  cidr_block              = var.public_subnet_cidr_blocks[each.value]
  availability_zone       = "${var.region}${each.value}"
  map_public_ip_on_launch = true


  tags = {
    Name = "${var.name}-public-subnet-${upper(each.value)}"
  }
}

resource "aws_subnet" "private-subnets-project1" {
  vpc_id                  = aws_vpc.vpc-project1.id
  for_each                = toset(var.availability_zones)
  cidr_block              = var.private_subnet_cidr_blocks[each.value]
  availability_zone       = "${var.region}${each.value}"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}-private-subnet-${upper(each.value)}"
  }
}
resource "aws_internet_gateway" "gw-project1" {
   
    vpc_id = aws_vpc.vpc-project1.id
    tags = {
        Name: "${var.name}-igw"
    }
}

resource "aws_default_route_table" "main-rtb" {
  
    default_route_table_id = aws_vpc.vpc-project1.default_route_table_id
    

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw-project1.id
    }
    tags = {
        Name: "${var.name}-main-rtb"
    }
}

resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.vpc-project1.id

  egress = [
    {
      rule_no    = 100
      protocol   = "-1"
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
      icmp_code  = -1
      icmp_type  = -1
      ipv6_cidr_block = null

    }
  ]

  ingress = [
    {
      rule_no       = 100
      protocol      = "-1"
      action        = "allow"
      cidr_block    = "0.0.0.0/0"
      from_port     = 0
      to_port       = 0
      icmp_code     = -1
      icmp_type     = -1
      ipv6_cidr_block = null
      ipv6_cidr_block = null
    }
  ]

  tags = {
    Name = "${var.name}-public-nacl"
  }
}

resource "aws_network_acl_association" "public_subnet_nacl" {
  for_each = toset(var.availability_zones)
  subnet_id          = aws_subnet.public-subnets-project1[each.value].id
  network_acl_id     = aws_network_acl.public_nacl.id
}
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public-subnets-project1[var.availability_zones[count.index]].id
  route_table_id = aws_default_route_table.main-rtb.id
}
//EC2
resource "aws_security_group" "sg-project1" {
  name        = "${var.name}-${var.security_group_name}"
  vpc_id      = aws_vpc.vpc-project1.id
  description = "upper(${var.name}) ${var.security_group_name}"
 
 dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = var.egress_ports
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.port == 0 ? "-1" : "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = egress.value.description
    }
  }
}

resource "aws_security_group" "sg-project1_nexp" {
  name        = "${var.name}-${var.security_group_name}-nexp"
  vpc_id      = aws_vpc.vpc-project1.id
  description = "upper(${var.name}) ${var.security_group_name} for node exporter"
 
 dynamic "ingress" {
    for_each = var.ingress_ports_nexp
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = var.egress_ports
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.port == 0 ? "-1" : "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = egress.value.description
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["${var.ami_owners}"]

  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["${var.ami_virtualization_type}"]
  }
}

resource "aws_instance" "node_exporter" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "${var.instance_type}"
  subnet_id     = aws_subnet.public-subnets-project1[var.availability_zones[0]].id
  security_groups = [aws_security_group.sg-project1_nexp.id]
  key_name = "${var.key_name}"
  availability_zone = "${var.region}${var.availability_zones[0]}"
  associate_public_ip_address = true
  user_data = file("${var.user_data_file_nexp}")
  tags = {
    Name = "${var.name}-node_exporter"
  }
  
}
data "template_file" "user_data_template" {
  template = file("${var.user_data_file_ps}")
  vars = {
    private_ip_value = aws_instance.node_exporter.private_ip
  }
}


resource "aws_instance" "project1-ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "${var.instance_type}"
  subnet_id     = aws_subnet.public-subnets-project1[var.availability_zones[0]].id
  security_groups = [aws_security_group.sg-project1.id]
  key_name = "${var.key_name}"
  availability_zone = "${var.region}${var.availability_zones[0]}"
  associate_public_ip_address = true
  
 user_data = data.template_file.user_data_template.rendered

  tags = {
    Name = "${var.name}-prometheus_server"
  }
  }







output "prometheus_grafana_instance_ip" {
  value = aws_instance.project1-ec2.public_ip
}

output "node_exporter_instance_ip" {
  value = aws_instance.node_exporter.public_ip
}