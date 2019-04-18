data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc}${var.vpc_filter_name}"]
  }
}

data "aws_region" "current" {}

data "aws_iam_policy_document" "es_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "es:ESHttpDelete",
      "es:ESHttpGet",
      "es:ESHttpHead",
      "es:ESHttpPost",
      "es:ESHttpPut",
    ]

    resources = [
      "${aws_elasticsearch_domain.es.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "es:DescribeElasticsearchDomain",
    ]

    resources = [
      "${aws_elasticsearch_domain.es.arn}",
    ]
  }
}

data "aws_iam_policy_document" "es_domain_document" {
  statement {
    effect = "Allow"

    condition {
      test     = "ArnLike"
      values   = ["${distinct(var.iam_roles_for_access)}"]
      variable = "aws:SourceArn"
    }

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = [
      "es:ESHttpDelete",
      "es:ESHttpGet",
      "es:ESHttpHead",
      "es:ESHttpPost",
      "es:ESHttpPut",
    ]

    resources = [
      "${aws_elasticsearch_domain.es.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    condition {
      test     = "ArnLike"
      values   = ["${distinct(var.iam_roles_for_access)}"]
      variable = "aws:SourceArn"
    }

    actions = [
      "es:DescribeElasticsearchDomain",
    ]

    resources = [
      "${aws_elasticsearch_domain.es.arn}",
    ]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    Type = "private"
  }
}
