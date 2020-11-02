variable "gcp_project" {
	type = string
	default = "vmware-ysung"
}

variable "gcp_region" {
  type    = string
  default = "us-central1"
}

variable "gcp_zone" {
  type    = string
  default = "us-central1-a"
}

variable "gcp_credentials" {
	type = string
	default = "~/.ssh/vmware-ysung.json"
}
variable "instance_type" {
  type = string
  default = "n2-standard-2"
}

variable "image_type" {
  type = string
  default = "ubuntu-os-cloud/ubuntu-2004-focal-v20201028"
}

variable "ssh_user" {
  type = string
  default = "ysung"
}

variable "ssh_pub" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}
