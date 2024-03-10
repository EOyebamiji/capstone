terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.12.1"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.26.0"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

data "aws_eks_cluster" "cluster_name" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster_name" {
  name = "${var.cluster_name}_auth"
}
provider "kubernetes" {
   host                   = data.aws_eks_cluster.cluster_name.endpoint
   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_name.certificate_authority[0].data)
   config_path = "~/.kube/config"
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_namespace" "kube-namespace" {
  metadata {
    name = "voting-app"
  }
}


provider "kubectl" {
   load_config_file       = false
   host                   = data.aws_eks_cluster.cluster_name.endpoint
   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_name.certificate_authority[0].data)
   token                  = data.aws_eks_cluster_auth.cluster_name_auth.token
   config_path            = "~/.kube/config"
}
