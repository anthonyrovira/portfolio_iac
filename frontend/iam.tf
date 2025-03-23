resource "aws_cloudfront_origin_access_identity" "frontend" {
  comment = "OAI for portfolio frontend"
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid = "1"
    actions   = [
        "s3:GetObject",      
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
    ]
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