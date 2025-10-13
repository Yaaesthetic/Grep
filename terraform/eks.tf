module "eks" {
  cluster_name    = var.cluster_name
  cluster_version = "1.30"
  tags = {
    Environment = "dev"
    Project     = "grep"
  }
}
