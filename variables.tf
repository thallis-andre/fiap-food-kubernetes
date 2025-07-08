variable "region" {
  default     = "us-east-1"
  description = "AWS Region"
}

variable "aws_account_id" {
  default     = ""
  description = "AWS Account Id"
}

variable "aws_cluster_name" {
  default     = "fiap-food-k8s"
  description = "The name of the EKS Cluster to Create"
}
