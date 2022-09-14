## TiKV nodes

data "template_file" "tikv_user_data" {
  template = file("tikv_server.yml")
}

resource "aws_instance" "tikv_0" {
  ami           = var.amis_x86
  instance_type = var.tikv_instance_type_x86
  key_name      = aws_key_pair.generated_key.key_name

  subnet_id                   = aws_subnet.subnet_0.id
  vpc_security_group_ids      = [aws_security_group.safety_sg.id]

  user_data = data.template_file.tikv_user_data.rendered

  private_ip = "10.0.1.20"
  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp3"
  }

  ebs_block_device {
    device_name = "/dev/xvdh"
    delete_on_termination = true
    volume_size = var.tikv_storage.size
    volume_type = var.tikv_storage.type
    iops        = var.tikv_storage.iops
    throughput  = var.tikv_storage.bandwidth

    tags = {
      Name = "${var.name}-tikv-0"
      usedby = var.name
      component = "${var.name}-tikv"
    }
  }

  tags = {
    Name = "${var.name}-tikv-0"
    usedby = var.name
    component = "${var.name}-tikv"
  }
}

resource "aws_instance" "tikv_1" {
  ami           = var.amis_x86
  instance_type = var.tikv_instance_type_x86
  key_name      = aws_key_pair.generated_key.key_name
  private_ip = "10.0.1.21"
  subnet_id                   = aws_subnet.subnet_0.id
  vpc_security_group_ids      = [aws_security_group.safety_sg.id]

  user_data = data.template_file.tikv_user_data.rendered

  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp3"
  }

  ebs_block_device {
    device_name = "/dev/xvdh"
    delete_on_termination = true
    volume_size = var.tikv_storage.size
    volume_type = var.tikv_storage.type
    iops        = var.tikv_storage.iops
    throughput  = var.tikv_storage.bandwidth
    tags = {
      Name = "${var.name}-tikv-1"
      usedby = var.name
      component = "${var.name}-tikv"
    }
  }

  tags = {
    Name = "${var.name}-tikv-1"
    usedby = var.name
    component = "${var.name}-tikv"
  }
}

resource "aws_instance" "tikv_2" {
  ami           = var.amis_x86
  instance_type = var.tikv_instance_type_x86
  key_name      = aws_key_pair.generated_key.key_name
  subnet_id                   = aws_subnet.subnet_0.id
  vpc_security_group_ids      = [aws_security_group.safety_sg.id]

  private_ip = "10.0.1.22"
  user_data = data.template_file.tikv_user_data.rendered

  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp3"
  }

  ebs_block_device {
    device_name = "/dev/xvdh"
    delete_on_termination = true
    volume_size = var.tikv_storage.size
    volume_type = var.tikv_storage.type
    iops        = var.tikv_storage.iops
    throughput  = var.tikv_storage.bandwidth
    tags = {
      Name = "${var.name}-tikv-2"
      usedby = var.name
      component = "${var.name}-tikv"
    }
  }

  tags = {
    Name = "${var.name}-tikv-2"
    usedby = var.name
    component = "${var.name}-tikv"
  }
}

output "tikv_0" {
  description = "tikv_0 ip"
  value       = aws_instance.tikv_0.private_ip
}

output "tikv_1" {
  description = "tikv_1 ip"
  value       = aws_instance.tikv_1.private_ip
}

output "tikv_2" {
  description = "tikv_2 ip"
  value       = aws_instance.tikv_2.private_ip
}

## TiDB nodes

resource "aws_instance" "tidb_0" {
  ami           = var.amis_x86
  instance_type = var.tidb_instance_type_x86
  key_name      = aws_key_pair.generated_key.key_name
  private_ip = "10.0.1.30"

  subnet_id                   = aws_subnet.subnet_0.id
  vpc_security_group_ids      = [aws_security_group.safety_sg.id]

  user_data = data.template_file.user_data.rendered

  root_block_device {
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp3"
  }

  tags = {
    Name = "${var.name}-tidb-0"
    usedby = var.name
    component = "${var.name}-tidb"
  }
}

# resource "aws_instance" "tidb_1" {
#   ami           = var.amis_x86
#   instance_type = var.tidb_instance_type_x86
#   key_name      = aws_key_pair.generated_key.key_name
#   private_ip = "10.0.1.31"
#   subnet_id                   = aws_subnet.subnet_0.id
#   vpc_security_group_ids      = [aws_security_group.safety_sg.id]

#   user_data = data.template_file.user_data.rendered

#   root_block_device {
#     delete_on_termination = true
#     volume_size           = 50
#     volume_type           = "gp3"
#   }

#   tags = {
#     Name = "${var.name}-tidb-1"
#     usedby = var.name
#     component = "${var.name}-tidb"
#   }
# }

resource "aws_lb_target_group_attachment" "tidb_attachment_0" {
  target_group_arn = aws_lb_target_group.tidb_cross_az_public.arn
  target_id        = aws_instance.tidb_0.id
  port             = 4000
}

# resource "aws_lb_target_group_attachment" "tidb_attachment_1" {
#   target_group_arn = aws_lb_target_group.tidb_cross_az_public.arn
#   target_id        = aws_instance.tidb_1.id
#   port             = 4000
# }

output "tidb_0" {
  description = "tidb_0 ip"
  value       = aws_instance.tidb_0.private_ip
}

# output "tidb_1" {
#   description = "tidb_1 ip"
#   value       = aws_instance.tidb_1.private_ip
# }

## PD nodes

# resource "aws_instance" "pd_0" {
#   ami           = var.amis_x86
#   instance_type = var.pd_instance_type
#   key_name      = aws_key_pair.generated_key.key_name
#   private_ip = "10.0.1.40"

#   subnet_id                   = aws_subnet.subnet_0.id
#   vpc_security_group_ids      = [aws_security_group.safety_sg.id]

#   user_data = data.template_file.user_data.rendered

#   root_block_device {
#     delete_on_termination = true
#     volume_size           = 50
#     volume_type           = "gp3"
#   }

#   tags = {
#     Name = "${var.name}-pd-0"
#     usedby = var.name
#     component = "${var.name}-pd"
#   }
# }

# output "pd_0" {
#   description = "pd_0 ip"
#   value       = aws_instance.pd_0.private_ip
# }
