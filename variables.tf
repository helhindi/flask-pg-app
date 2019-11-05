# Copyright 2019 Jetstack Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# gcp_project_id = {
#   default = "<your-gcp-project-id>"
# }
variable "gcp_project_id" {
  default = "<your-gcp_project_id>"
}

# cluster_name = {
#   default = "guestbook"
# }

variable "cluster_name" {
  default = "guestbook"
}

# The location (region or zone) in which the cluster will be created. If you
# specify a zone (such as us-central1-a), the cluster will be a zonal cluster.
# If you specify a region (such as us-west1), the cluster will be a regional
# cluster.

# gcp_location = {
#   default = "europe-west2-a"
# }
variable "gcp_location" {
  default = "europe-west2-a"
}


# daily_maintenance_window_start_time = {
#   default = "03:00"
# }
variable "daily_maintenance_window_start_time" {
  default = "03:00"
}

# node_pools = {
#   default = [
#     {
#       name                       = "default"
#       initial_node_count         = 1
#       autoscaling_min_node_count = 2
#       autoscaling_max_node_count = 3
#       management_auto_upgrade    = true
#       management_auto_repair     = true
#       node_config_machine_type   = "n1-standard-1"
#       node_config_disk_type      = "pd-standard"
#       node_config_disk_size_gb   = 20
#       node_config_preemptible    = false
#     },
# ]
# }

variable "node_pools" {
  default = [
  {
    name                       = "default"
    initial_node_count         = 1
    autoscaling_min_node_count = 2
    autoscaling_max_node_count = 3
    management_auto_upgrade    = true
    management_auto_repair     = true
    node_config_machine_type   = "n1-standard-1"
    node_config_disk_type      = "pd-standard"
    node_config_disk_size_gb   = 20
    node_config_preemptible    = false
  },
]
}

# vpc_network_name = "vpc-network"
variable "vpc_network_name" {
  type = string
  default = "vpc-network"
  description = <<EOF
The name of the Google Compute Engine network to which the cluster is
connected.
EOF
}

# vpc_subnetwork_name = "vpc-subnetwork"
variable "vpc_subnetwork_name" {
  type = string
  default = "vpc-subnetwork"
  description = <<EOF
The name of the Google Compute Engine subnetwork in which the cluster's
instances are launched.
EOF
}

# vpc_subnetwork_cidr_range = "10.0.16.0/20"
variable "vpc_subnetwork_cidr_range" {
  type = string
  default = "10.0.16.0/20"
}

# cluster_secondary_range_name = "pods"
variable "cluster_secondary_range_name" {
  type    = string
  default = "pods"
  description = <<EOF
The name of the secondary range to be used as for the cluster CIDR block.
The secondary range will be used for pod IP addresses. This must be an
existing secondary range associated with the cluster subnetwork.
EOF
}

# cluster_secondary_range_cidr = "10.16.0.0/12"
variable "cluster_secondary_range_cidr" {
  type    = string
  default = "10.16.0.0/12"
}

# services_secondary_range_name = "services"
variable "services_secondary_range_name" {
  type = string
  default = "services"
  description = <<EOF
The name of the secondary range to be used as for the services CIDR block.
The secondary range will be used for service ClusterIPs. This must be an
existing secondary range associated with the cluster subnetwork.
EOF
}

# services_secondary_range_cidr = "10.1.0.0/20"
variable "services_secondary_range_cidr" {
  type = string
  default = "10.1.0.0/20"
}

# master_ipv4_cidr_block = "172.16.0.0/28"
variable "master_ipv4_cidr_block" {
  type = string
  default = "172.16.0.0/28"
  description = <<EOF
The IP range in CIDR notation to use for the hosted master network. This
range will be used for assigning internal IP addresses to the master or set
of masters, as well as the ILB VIP. This range must not overlap with any
other ranges in use within the cluster's network.
EOF
}

# access_private_images = "false"
variable "access_private_images" {
  type    = string
  default = "false"
  description = <<EOF
Whether to create the IAM role for storage.objectViewer, required to access
GCR for private container images.
EOF
}

# http_load_balancing_disabled = "false"
variable "http_load_balancing_disabled" {
  type    = string
  default = "false"

  description = <<EOF
  The status of the HTTP (L7) load balancing controller addon, which makes it
  easy to set up HTTP load balancers for services in a cluster. It is enabled
  by default; set disabled = true to disable.
  EOF

}

variable "master_authorized_networks_cidr_blocks" {
  type = list(map(string))
  default = [
    {
      # External network that can access Kubernetes master through HTTPS. Must
      # be specified in CIDR notation. This block should allow access from any
      # address, but is given explicitly to prevernt Google's defaults from
      # fighting with Terraform.
      cidr_block = "0.0.0.0/0"
      # Field for users to identify CIDR blocks.
      display_name = "default"
    },
  ]

  description = <<EOF
Defines up to 20 external networks that can access Kubernetes master
through HTTPS.
EOF
}

# variable "master_authorized_networks_cidr_blocks" {
#   default = [
#   {
#     cidr_block = "0.0.0.0/0"
#     display_name = "default"
#   },
# ]
# }
