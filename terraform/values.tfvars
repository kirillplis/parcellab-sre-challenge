aws_region       = "eu-central-1"
aws_account_id   = "211125442702"
aws_account_name = "playground"
repo             = "greet-api"

vpc_cidr           = "10.60.0.0/16"
azs                = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
public_subnets     = ["10.60.0.0/20", "10.60.16.0/20", "10.60.32.0/20"]
private_subnets    = ["10.60.80.0/20", "10.60.96.0/20", "10.60.112.0/20"]

eks_clusters = {
  primary-eks = {
    cluster_version = "1.29"

    #clusterAddons
    coredns_version     = "v1.9.3-eksbuild.5"
    kube_proxy_version  = "v1.26.6-eksbuild.2"
    vpc_cni_version     = "v1.13.3-eksbuild.1"
    aws-ebs-csi-version = "v1.21.0-eksbuild.1"

    eks_managed_node_groups = {
      spot = {
        name = "spot"

        desired_size = 8
        max_size     = 8
        min_size     = 8

        instance_types = ["t2.micro"]
        capacity_type  = "SPOT"
        labels = {
          "capacity_type" = "SPOT"
        }
      }
    }
    cluster_service_ipv4_cidr = "10.82.0.0/16"
  }
}

# roles for GKE service accounts to assume
sa_iam_roles = {
  external-secrets = {
    name        = "external-secrets"
    description = "Access for External Secrets operator to use AWS Secrets Manager"
    statement = [
      {
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Resource": [
          "arn:aws:secretsmanager:eu-central-1:211125442702:secret:*"
        ]
      }
    ]
  }
}