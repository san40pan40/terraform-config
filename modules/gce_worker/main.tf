variable "account_json_com" {}
variable "account_json_org" {}
variable "config_com" {}
variable "config_com_free" {}
variable "config_org" {}
variable "env" {}
variable "github_users" {}
variable "index" {}
variable "instance_count_com" {}
variable "instance_count_com_free" {}
variable "instance_count_org" {}

variable "machine_type" {
  default = "n1-standard-1"
}

variable "project" {}
variable "region" {}
variable "subnetwork_workers" {}
variable "syslog_address_com" {}
variable "syslog_address_org" {}
variable "worker_docker_self_image" {}
variable "worker_image" {}

variable "zones" {
  default = ["a", "b", "c", "f"]
}

data "template_file" "cloud_init_env_com" {
  template = <<EOF
export TRAVIS_WORKER_SELF_IMAGE="${var.worker_docker_self_image}"
EOF
}

data "template_file" "cloud_config_com" {
  template = "${file("${path.module}/cloud-config.yml.tpl")}"

  vars {
    assets           = "${path.module}/../../assets"
    cloud_init_env   = "${data.template_file.cloud_init_env_com.rendered}"
    gce_account_json = "${var.account_json_com}"
    here             = "${path.module}"
    syslog_address   = "${var.syslog_address_com}"
    worker_config    = "${var.config_com}"

    docker_env = <<EOF
export TRAVIS_DOCKER_DISABLE_DIRECT_LVM=1
EOF

    github_users_env = <<EOF
export GITHUB_USERS='${var.github_users}'
EOF
  }
}

resource "null_resource" "worker_com_validation" {
  triggers {
    config_signature = "${sha256(data.template_file.cloud_config_com.rendered)}"
  }

  provisioner "local-exec" {
    command = <<EOF
exec ${path.module}/../../bin/travis-worker-verify-config \
  "${base64encode(data.template_file.cloud_config_com.rendered)}"
EOF
  }
}

resource "google_compute_instance" "worker_com" {
  count = "${var.instance_count_com}"
  name  = "${var.env}-${var.index}-worker-com-${element(var.zones, count.index % length(var.zones))}-${(count.index / length(var.zones)) + 1}-gce"

  machine_type = "${var.machine_type}"
  zone         = "${var.region}-${element(var.zones, count.index % length(var.zones))}"
  tags         = ["worker", "${var.env}", "com"]
  project      = "${var.project}"

  boot_disk {
    auto_delete = true

    initialize_params {
      image = "${var.worker_image}"
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = "${var.subnetwork_workers}"

    access_config {
      # ephemeral ip
    }
  }

  metadata {
    "block-project-ssh-keys" = "true"
    "user-data"              = "${data.template_file.cloud_config_com.rendered}"
  }

  depends_on = ["null_resource.worker_com_validation"]

  lifecycle {
    ignore_changes = ["disk", "boot_disk"]
  }
}

data "template_file" "cloud_init_env_com_free" {
  template = <<EOF
export TRAVIS_WORKER_SELF_IMAGE="${var.worker_docker_self_image}"
EOF
}

data "template_file" "cloud_config_com_free" {
  template = "${file("${path.module}/cloud-config.yml.tpl")}"

  vars {
    assets           = "${path.module}/../../assets"
    cloud_init_env   = "${data.template_file.cloud_init_env_com_free.rendered}"
    gce_account_json = "${var.account_json_com}"
    here             = "${path.module}"
    syslog_address   = "${var.syslog_address_com}"
    worker_config    = "${var.config_com_free}"

    docker_env = <<EOF
export TRAVIS_DOCKER_DISABLE_DIRECT_LVM=1
EOF

    github_users_env = <<EOF
export GITHUB_USERS='${var.github_users}'
EOF
  }
}

resource "null_resource" "worker_com_free_validation" {
  triggers {
    config_signature = "${sha256(data.template_file.cloud_config_com_free.rendered)}"
  }

  provisioner "local-exec" {
    command = <<EOF
exec ${path.module}/../../bin/travis-worker-verify-config \
  "${base64encode(data.template_file.cloud_config_com_free.rendered)}"
EOF
  }
}

resource "google_compute_instance" "worker_com_free" {
  count = "${var.instance_count_com_free}"
  name  = "${var.env}-${var.index}-worker-com-free-${element(var.zones, count.index % length(var.zones))}-${(count.index / length(var.zones)) + 1}-gce"

  machine_type = "${var.machine_type}"
  zone         = "${var.region}-${element(var.zones, count.index % length(var.zones))}"
  tags         = ["worker", "${var.env}", "com", "free"]
  project      = "${var.project}"

  boot_disk {
    auto_delete = true

    initialize_params {
      image = "${var.worker_image}"
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = "${var.subnetwork_workers}"

    access_config {
      # ephemeral ip
    }
  }

  metadata {
    "block-project-ssh-keys" = "true"
    "user-data"              = "${data.template_file.cloud_config_com_free.rendered}"
  }

  depends_on = ["null_resource.worker_com_free_validation"]

  lifecycle {
    ignore_changes = ["disk", "boot_disk"]
  }
}

data "template_file" "cloud_init_env_org" {
  template = <<EOF
export TRAVIS_WORKER_SELF_IMAGE="${var.worker_docker_self_image}"
EOF
}

data "template_file" "cloud_config_org" {
  template = "${file("${path.module}/cloud-config.yml.tpl")}"

  vars {
    assets           = "${path.module}/../../assets"
    cloud_init_env   = "${data.template_file.cloud_init_env_org.rendered}"
    gce_account_json = "${var.account_json_org}"
    here             = "${path.module}"
    syslog_address   = "${var.syslog_address_org}"
    worker_config    = "${var.config_org}"

    docker_env = <<EOF
export TRAVIS_DOCKER_DISABLE_DIRECT_LVM=1
EOF

    github_users_env = <<EOF
export GITHUB_USERS='${var.github_users}'
EOF
  }
}

resource "null_resource" "worker_org_validation" {
  triggers {
    config_signature = "${sha256(data.template_file.cloud_config_org.rendered)}"
  }

  provisioner "local-exec" {
    command = <<EOF
exec ${path.module}/../../bin/travis-worker-verify-config \
  "${base64encode(data.template_file.cloud_config_org.rendered)}"
EOF
  }
}

resource "google_compute_instance" "worker_org" {
  count = "${var.instance_count_org}"
  name  = "${var.env}-${var.index}-worker-org-${element(var.zones, count.index % length(var.zones))}-${(count.index / length(var.zones)) + 1}-gce"

  machine_type = "${var.machine_type}"
  zone         = "${var.region}-${element(var.zones, count.index % length(var.zones))}"
  tags         = ["worker", "${var.env}", "org"]
  project      = "${var.project}"

  boot_disk {
    auto_delete = true

    initialize_params {
      image = "${var.worker_image}"
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = "${var.subnetwork_workers}"

    access_config {
      # ephemeral ip
    }
  }

  metadata {
    "block-project-ssh-keys" = "true"
    "user-data"              = "${data.template_file.cloud_config_org.rendered}"
  }

  depends_on = ["null_resource.worker_org_validation"]

  lifecycle {
    ignore_changes = ["disk", "boot_disk"]
  }
}
