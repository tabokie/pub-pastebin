variable "name" {
  description = "Name"
  default     = "xinye-test"
}

variable "region" {
  description = "AWS region"
  default     = "ap-southeast-1"
}

variable "tikv_storage" {
  default = {
    type = "gp3"
    size = 700
    iops = 3000
    bandwidth = 300
  }
}

# variable "tidb_instance_type_arm" {
#   description = "Arm EC2 for TiDB"
#   default     = "m6g.large"
# }
variable "tidb_instance_type_x86" {
  description = "x86 EC2 for TiDB"
  default     = "c5.4xlarge"
}

# variable "tikv_instance_type_arm" {
#   description = "Arm EC2 for TiKV"
#   default     = "m6g.large"
# }
variable "tikv_instance_type_x86" {
  description = "x86 EC2 for TiKV"
  default     = "r5.xlarge"
}

variable "pd_instance_type" {
  description = "EC2 for PD"
  default     = "c5.2xlarge"
}

variable "tools_instance_type" {
  description = "EC2 for grafana, prometheus, bastion"
  default     = "t3.large"
}

variable "bastion_storage_size" {
  description = "bastion storage size"
  default     = 10
}

variable "amis_arm" {
  description = "arm AMI"
  default     = "ami-076712f71077c904e"
}
variable "amis_x86" {
  description = "x86 AMI"
  default     = "ami-0ff89c4ce7de192ea"
}
