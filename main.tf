provider "google" {
	credentials = file(var.gcp_credentials)
	project	= var.gcp_project
	region = var.gcp_region
	zone = var.gcp_zone
}

resource "random_id" "instance_id" {
	byte_length = 8
}

resource "google_compute_firewall" "prometheus" {
	name = "default-prometheus"
	network = "default"
	allow {
		protocol = "tcp"
		ports = ["9090","3000"]
	}
	source_tags = ["prometheus"]
}

resource "google_compute_disk" "pg_source" {
	name = "pgsource"
	type = "pd-ssd"
}

resource "google_compute_disk" "pg_data" {
	name = "pgdata"
	type = "pd-ssd"
}

resource "google_compute_instance" "default" {
	name = "pg-vm-${random_id.instance_id.hex}"
	machine_type = var.instance_type

	boot_disk {
		initialize_params {
			image = var.image_type
		}
	}

	attached_disk {
		source = google_compute_disk.pg_source.name
	}
	attached_disk {
		source = google_compute_disk.pg_data.name
	}

	metadata = {
		ssh-keys = "${var.ssh_user}:${file(var.ssh_pub)}"
	}

	metadata_startup_script = file("scripts/pd_disk_mount.sh")

	network_interface {
		network = "default"

		access_config{

		}
	}

	tags = ["prometheus"]
}

resource "local_file" "ansible_host" {
 content = templatefile("templates/hosts.tpl",
	   {
		 default_hosts = google_compute_instance.default.*.network_interface.0.access_config.0.nat_ip
	   }
	)
 filename = "${path.module}/hosts"
}

resource "null_resource" "ansible_playbook" {
  depends_on = [
	local_file.ansible_host,
  ]
  provisioner "local-exec" {
    command = "ansible-playbook main.yaml"
  }
}


output "ip" {
	value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}