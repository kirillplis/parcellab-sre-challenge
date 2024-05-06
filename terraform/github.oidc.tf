data "tls_certificate" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_oidc" {
 url             = "https://token.actions.githubusercontent.com"
 client_id_list  = ["sts.amazonaws.com" ]
 thumbprint_list = data.tls_certificate.github_oidc.certificates[*].sha1_fingerprint
}

data "aws_iam_policy_document" "github_oidc_allow" {
 statement {
   effect  = "Allow"
   actions = ["sts:AssumeRoleWithWebIdentity"]
   principals {
     type        = "Federated"
     identifiers = [aws_iam_openid_connect_provider.github_oidc.arn]
   }
   condition {
     test     = "StringLike"
     variable = "token.actions.githubusercontent.com:sub"
     values   = [
      "repo:kirillplis/parcellab-sre-challenge:*",
      ]
   }
   condition {
     test     = "StringEquals"
     variable = "token.actions.githubusercontent.com:aud"
     values   = ["sts.amazonaws.com"]
   }
 }
}

resource "aws_iam_policy" "ecr_write" {
  name        = "ECRWrite"
  path        = "/"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ecr:PutLifecyclePolicy",
                "ecr:StartImageScan",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken",
                "ecr:UploadLayerPart",
                "ecr:PutRegistryScanningConfiguration",
                "ecr:ListImages",
                "ecr:PutImage",
                "ecr:BatchImportUpstreamImage",
                "ecr:BatchGetImage",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeImages",
                "ecr:DescribeRepositories",
                "ecr:StartLifecyclePolicyPreview",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:ReplicateImage",
                "ecr:PutReplicationConfiguration"
            ],
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_role" "github_oidc_role" {
 name               = "GithubActionsRole"
 assume_role_policy = data.aws_iam_policy_document.github_oidc_allow.json
 managed_policy_arns = [aws_iam_policy.ecr_write.arn]
}

