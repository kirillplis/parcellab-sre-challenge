variable "sa_iam_roles" {}

data "aws_iam_policy_document" "sa_assume_role_with_web_identity" {
  for_each = var.sa_iam_roles

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks["primary-eks"].oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks["primary-eks"].oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "${module.eks["primary-eks"].oidc_provider}:sub"
      values   = ["system:serviceaccount:${can(each.value.namespace) ? each.value.namespace : each.key}:${each.key}"]
    }
  }
}

resource "aws_iam_role" "sa_roles" {
  for_each = var.sa_iam_roles

  name               = each.key
  assume_role_policy = data.aws_iam_policy_document.sa_assume_role_with_web_identity[each.key].json
}

resource "aws_iam_policy" "sa_policies" {
  for_each = var.sa_iam_roles

  name        = each.value.name
  description = each.value.description

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : each.value.statement
  })
}

resource "aws_iam_role_policy_attachment" "sa_policy_attachments" {
  for_each = var.sa_iam_roles

  role       = aws_iam_role.sa_roles[each.key].name
  policy_arn = aws_iam_policy.sa_policies[each.key].arn
}