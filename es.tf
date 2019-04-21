provider "aws" {
  region = "${var.region}"
}

resource "aws_security_group" "sg" {
  name        = "${lower(var.app_name)}-${var.vpc}-es-sg"
  description = "ES Security Group for ${var.app_name}"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  tags {
    Group       = "${var.owner}"
    Application = "${var.app_name}"
    Environment = "${var.account}"
  }
}

resource "aws_security_group_rule" "allow_client_to_es" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg.id}"
  cidr_blocks       = ["${data.aws_vpc.vpc.cidr_block}"]
  to_port           = 443
  type              = "ingress"
}

resource "aws_iam_policy" "es_policy" {
  name        = "${var.app_name}-es_policy-${data.aws_region.current.name}"
  description = "A policy to access ${var.app_name} ES cluster"
  policy      = "${data.aws_iam_policy_document.es_policy_document.json}"
}

resource "aws_elasticsearch_domain_policy" "es_policy" {
  access_policies = "${data.aws_iam_policy_document.es_domain_document.json}"
  domain_name     = "${aws_elasticsearch_domain.es.domain_name}"
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${lower(var.app_name)}-es"
  elasticsearch_version = "${var.es_version}"

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
    "indices.fielddata.cache.size"           = "40"
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "${var.volume_type}"
    volume_size = "${var.volume_size}"
  }

  encrypt_at_rest {
    enabled = "${var.is_encrypt}"
  }

  cluster_config {
    instance_type            = "${var.instance_type }"
    instance_count           = "${var.instance_count}"
    dedicated_master_enabled = false
//    dedicated_master_type    = "m4.large.elasticsearch"
//    dedicated_master_count   = 3
    zone_awareness_enabled   = false
  }

  snapshot_options {
    automated_snapshot_start_hour = "${lookup(var.automated_snapshot_start_hour, data.aws_region.current.name, 1)}"
  }

  tags {
    Application = "${var.app_name}"
    Environment = "${var.account}"
    Version     = "${var.es_version}"
  }

  vpc_options {
    security_group_ids = [
      "${aws_security_group.sg.id}",
    ]

    subnet_ids = [
      "${element(data.aws_subnet_ids.private.ids, 0)}",
    ]

    //      "${element(data.aws_subnet_ids.private.ids, 1)}",
  }
}
