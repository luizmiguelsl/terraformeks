data "http" "eks-ALBIngressControllerIAMPolicy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.9/docs/examples/iam-policy.json"
}

resource "aws_iam_policy" "eks-ALBIngressControllerIAMPolicy" {
  name   = "${module.transformacao-digital.cluster_id}-iam-eks-ALBIngressControllerIAMPolicy-cluster"
  policy = data.http.eks-ALBIngressControllerIAMPolicy.body
}

resource "kubernetes_cluster_role" "alb_ingress_controller" {
  depends_on = [aws_iam_policy.eks-ALBIngressControllerIAMPolicy]
  metadata {
    name = "alb-ingress-controller"
    labels = {
      "app.kubernetes.io/name" = "alb-ingress-controller"
    }
  }

  rule {
    api_groups = ["", "extensions"]
    resources  = ["configmaps", "endpoints", "events", "ingresses", "ingresses/status", "services"]
    verbs      = ["create", "get", "list", "update", "watch", "patch"]
  }

  rule {
    api_groups = ["", "extensions"]
    resources  = ["nodes", "pods", "secrets", "services", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "alb_ingress_controller" {
  metadata {
    name   = kubernetes_cluster_role.alb_ingress_controller.metadata.0.name
    labels = kubernetes_cluster_role.alb_ingress_controller.metadata.0.labels
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.alb_ingress_controller.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.alb_ingress_controller.metadata.0.name
    namespace = "kube-system"
  }
}

resource "kubernetes_service_account" "alb_ingress_controller" {
  metadata {
    name      = kubernetes_cluster_role.alb_ingress_controller.metadata.0.name
    labels    = kubernetes_cluster_role.alb_ingress_controller.metadata.0.labels
    namespace = "kube-system"
  }
}

resource "kubernetes_deployment" "alb_ingress_controller" {
  metadata {
    name      = kubernetes_cluster_role_binding.alb_ingress_controller.metadata.0.name
    labels    = kubernetes_cluster_role_binding.alb_ingress_controller.metadata.0.labels
    namespace = "kube-system"
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "alb-ingress-controller"
      }
    }
    template {
      metadata {
        labels = kubernetes_cluster_role_binding.alb_ingress_controller.metadata.0.labels
      }
      spec {
        automount_service_account_token = true
        container {
          name = "alb-ingress-controller"
          args = [
            "--ingress-class=alb",
            "--cluster-name=${data.aws_eks_cluster.cluster.name}",
            "--v",
            "5",
            "--aws-api-debug"
          ]
          image = "docker.io/amazon/aws-alb-ingress-controller:v1.1.9"
        }
        service_account_name = "alb-ingress-controller"
      }
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks-EKSALBIngressController" {
  policy_arn = aws_iam_policy.eks-ALBIngressControllerIAMPolicy.arn
  role       = module.transformacao-digital.worker_iam_role_name
}
