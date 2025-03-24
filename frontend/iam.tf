resource "aws_cloudfront_origin_access_identity" "frontend" {
  comment = "OAI for anthonyrovira.com"
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid = "1"
    actions   = ["s3:GetObject"] # Allow read access to the bucket
    resources = ["${aws_s3_bucket.frontend.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.frontend.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

data "aws_iam_policy_document" "github_actions" {
  statement {
    actions   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
    resources = ["${aws_s3_bucket.frontend.arn}/*", aws_s3_bucket.frontend.arn]
  }
}

resource "aws_iam_user" "github_actions" {
  name = "github-actions-frontend"
}

resource "aws_iam_user_policy" "github_actions" {
  user   = aws_iam_user.github_actions.name
  policy = data.aws_iam_policy_document.github_actions.json
}