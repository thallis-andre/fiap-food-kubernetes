provider "aws" {
  region = var.region
}

resource "aws_eks_cluster" "fiap_food_eks" {
  name     = var.aws_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  version = "1.30"
  upgrade_policy {
    support_type = "STANDARD"
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {

    subnet_ids = [
      aws_subnet.fiap_food_pub_subnet_1a.id,
      aws_subnet.fiap_food_pub_subnet_1b.id,
      aws_subnet.fiap_food_priv_subnet_1a.id,
      aws_subnet.fiap_food_priv_subnet_1b.id,
    ]

    public_access_cidrs     = ["0.0.0.0/0"]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = []
}

resource "aws_eks_node_group" "fiap_food_eks_node_group" {
  cluster_name    = var.aws_cluster_name
  node_group_name = "${var.aws_cluster_name}-nodegroup"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  instance_types  = ["t3.small"]
  disk_size       = 20
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "ON_DEMAND"

  subnet_ids = [
    aws_subnet.fiap_food_priv_subnet_1a.id,
    aws_subnet.fiap_food_priv_subnet_1b.id,
  ]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  tags = {
    Name = "${var.aws_cluster_name}-nodegroup"
  }

  depends_on = [
    aws_eks_cluster.fiap_food_eks
  ]
}

resource "aws_eks_addon" "kubeproxy" {
  cluster_name                = aws_eks_cluster.fiap_food_eks.name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.30.0-eksbuild.3"
  resolve_conflicts_on_update = "PRESERVE"
  depends_on = [
    aws_eks_cluster.fiap_food_eks,
    aws_eks_node_group.fiap_food_eks_node_group,
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.fiap_food_eks.name
  addon_name                  = "coredns"
  addon_version               = "v1.11.1-eksbuild.8"
  resolve_conflicts_on_update = "PRESERVE"
  depends_on = [
    aws_eks_cluster.fiap_food_eks,
    aws_eks_node_group.fiap_food_eks_node_group,
  ]
}

output "fiap_food_vpc_id" {
  value = aws_vpc.fiap_food_vpc.id
}

output "fiap_food_priv_subnet_1a_id" {
  value = aws_subnet.fiap_food_priv_subnet_1a.id
}

output "fiap_food_priv_subnet_1b_id" {
  value = aws_subnet.fiap_food_priv_subnet_1b.id
}
