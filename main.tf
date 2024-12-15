resource "aws_s3_bucket" "cm-cv-bucket" {
  bucket = var.bucketname

  tags = {
    Name = "cm-cv"
  }
}

resource "aws_s3_bucket_ownership_controls" "cm-cv-bucket-ownership" {
  bucket = aws_s3_bucket.cm-cv-bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "cm-cv-bucket-access" {
  bucket = aws_s3_bucket.cm-cv-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "cm-cv-bucket-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.cm-cv-bucket-ownership,
    aws_s3_bucket_public_access_block.cm-cv-bucket-access
  ]

  bucket = aws_s3_bucket.cm-cv-bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "cm-cv-webconfig" {
  bucket = aws_s3_bucket.cm-cv-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_bucket_acl.cm-cv-bucket-acl]
}

# === #
# Files

data "github_repository_file" "origin-repo-index" {
  provider   = github
  repository = "caffeinated-minds/faviobecker.dev"
  file       = "index.html"
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.cm-cv-bucket.id
  key          = "index.html"
  content      = data.github_repository_file.origin-repo-index.content
  acl          = "public-read"
  content_type = "text/html"
}

data "github_repository_file" "origin-repo-error" {
  provider   = github
  repository = "caffeinated-minds/faviobecker.dev"
  file       = "error.html"
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.cm-cv-bucket.id
  key          = "error.html"
  content      = data.github_repository_file.origin-repo-error.content
  acl          = "public-read"
  content_type = "text/html"
}

data "github_repository_file" "origin-repo-about" {
  provider   = github
  repository = "caffeinated-minds/faviobecker.dev"
  file       = "about.html"
}

resource "aws_s3_object" "about" {
  bucket       = aws_s3_bucket.cm-cv-bucket.id
  key          = "about.html"
  content      = data.github_repository_file.origin-repo-about.content
  acl          = "public-read"
  content_type = "text/html"
}

# data "github_repository_file" "origin-repo-output" {
#   provider   = github
#   repository = "caffeinated-minds/faviobecker.dev"
#   file       = "output.css"
# }

data "http" "origin-repo-output" {
  url = "https://raw.githubusercontent.com/caffeinated-minds/faviobecker.dev/refs/heads/master/output.css"
}


resource "aws_s3_object" "output" {
  bucket       = aws_s3_bucket.cm-cv-bucket.id
  key          = "output.css"
  content      = data.http.origin-repo-output.response_body
  acl          = "public-read"
  content_type = "text/css"
}

# data "github_repository_file" "origin-repo-outputCSS" {
#   provider   = github
#   repository = "caffeinated-minds/faviobecker.dev"
#   file        = "output*"
# }

# resource "aws_s3_object" "output" {
#   bucket  = aws_s3_bucket.cm-cv-bucket.id
#   key     = "output.css"
#   content = data.github_repository_file.origin-repo-outputCSS.content
#   # source       = "src/output.css"
#   acl = "public-read"
#   content_type = "text/css"
# }

# === #
# repo
resource "github_repository" "cm-cv-repo" {
  name        = "cm-cv-repo"
  description = "This repo was created using Terraform."
  visibility  = "public"
}


# === #
# Set budget exercise

resource "aws_budgets_budget" "cost" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = "10"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2024-12-14_15:36"
}