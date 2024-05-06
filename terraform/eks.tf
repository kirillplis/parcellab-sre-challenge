variable "eks_clusters" {
  type = map(any)
}

module "eks" {
  for_each = var.eks_clusters
  source   = "terraform-aws-modules/eks/aws"
  version  = "19.13.1"


  cluster_name    = "${var.aws_account_name}-${each.key}"
  cluster_version = each.value.cluster_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
      most_recent = true
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
      most_recent = true
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
      most_recent = true
    }
  }

  vpc_id                    = module.primary-vpc.vpc_id
  cluster_service_ipv4_cidr = each.value.cluster_service_ipv4_cidr

  subnet_ids = [
    module.primary-vpc.private_subnets[0], # eu-central-1a
    module.primary-vpc.private_subnets[1], # eu-central-1b
    module.primary-vpc.private_subnets[2], # eu-central-1c
  ]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    iam_role_attach_cni_policy = true
    create_security_group      = false
  }

  cluster_security_group_name                = "${var.aws_account_name}-${each.key}"
  cluster_security_group_description         = "Security group for ${var.aws_account_name}-${each.key} kubernetes cluster"
  create_cluster_primary_security_group_tags = true

  # Add to provide similar level of acces as v17.x
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }

    ingress_allow_all = {
      type             = "ingress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description                   = "Control plane to nodes on ephemeral ports"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_self_all = {
      description = "allow connections from EKS to EKS (internal calls)"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  eks_managed_node_groups = each.value.eks_managed_node_groups
  manage_aws_auth_configmap = false
  aws_auth_roles = []
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.28.0"

  role_name             = "ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks["primary-eks"].oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}