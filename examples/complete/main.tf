terraform {
  required_providers {
    airtelcloud = {
      source  = "Airtel-Cloud-Platform/airtelcloud"
      version = ">= 1.2.6"
    }
  }
}

provider "airtelcloud" {
  api_endpoint = "https://south.cloud.airtel.in"
  api_key      = var.airtel_api_key
  api_secret   = var.airtel_api_secret
  region       = "south"
  organization = var.organization
  project_name = var.project_name
}

module "asg" {
  source = "../../"

  name              = "${var.resource_prefix}-asg-lb-3"
  vpc_name          = "copper-vpc1"
  subnet            = "proxy-test-subnet"
  availability_zone = "S1"

  flavor_name          = "ccd.Large"
  image_name           = "Ubuntu22_04_Sep2026"
  security_group_names = ["akash-122"]
  keypair_name         = "sods"

  minimum_size  = 1
  maximum_size  = 3
  desired_count = 1

  scale_up_step_size   = 1
  scale_down_step_size = 1
  scaling_interval     = 2
  cooloff_period       = 10
  termination_policy   = "oldest"
  drain_period         = 0

  scaleup_rules = [{
    metric_type      = "cpu"
    aggregation_type = "avg"
    target_value     = 60
  }]

  scaledown_rules = [{
    metric_type      = "cpu"
    aggregation_type = "avg"
    target_value     = 30
  }]

  labels    = ["app", "production"]
  disk_size = 100

  load_balancer = {
    name                  = "testviveklbs117sep"
    host_name             = "${var.resource_prefix}-asg-vs"
    vip                   = "10.29.15.124"
    protocol              = "TCP"
    port                  = 1234
    routing_algorithm     = "ROUND_ROBIN"
    pool_name             = "ash-pool"
    pool_port             = 12
    max_connections       = 100
    health_check_interval = 5
    health_check_timeout  = 16
    pool_monitor_protocol = "TCP"
    enable_persistance    = false
  }

  timeouts = {
    create = "30m"
    delete = "30m"
  }
}
