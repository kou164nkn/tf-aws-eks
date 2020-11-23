variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zone" {
  default = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

variable "eks_cluster_version" {
  default = "1.18"
}

variable "eks_worker_version" {
  default = "1.18"
}

# == WorkerNode Instance Parameters =======================
variable "ami_type" {
  default = "AL2_x86_64"
}

variable "disk_size" {
  default = 20
}

variable "instance_types" {
  default = ["t3.medium"]
}

variable "desired_size" {
  default = 3
}

variable "max_size" {
  default = 4
}

variable "min_size" {
  default = 2
}
# =========================================================