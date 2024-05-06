variable "account_ids" {
  default = [
    "211125442702"
  ]
}

resource "aws_ecr_repository" "repo" {
  name = "greet-api"
}

data "aws_iam_policy_document" "repo" {
  statement {
    sid    = "pull"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.account_ids
    }

    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
  }
}

resource "aws_ecr_repository_policy" "repo" {
  repository = aws_ecr_repository.repo.name
  policy     = data.aws_iam_policy_document.repo.json
}
