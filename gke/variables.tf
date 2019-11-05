#####################################################################
# Variables
#####################################################################
variable "project" {}
variable "region" {
  default = "europe-west2"
}
variable "location" {
  default = "eu-west2-a"
}
variable "environment" {
  default = "develop"
}
variable "username" {
  default = "admin"
}
variable "password" {}