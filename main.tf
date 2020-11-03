provider "google" {
	credentials = file(var.gcp_credentials)
	project	= var.gcp_project
	region = var.gcp_region
	zone = var.gcp_zone
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

resource "google_compute_disk" "prom_data" {
	name = "promdata"
	type = "pd-ssd"
}

resource "google_compute_instance" "prometheus" {
	name = "prometheus"
	machine_type = var.instance_type

	boot_disk {
		initialize_params {
			image = var.image_type
		}
	}

	attached_disk {
		source = google_compute_disk.prom_data.name
	}

	metadata = {
		ssh-keys = "${var.ssh_user}:${file(var.ssh_pub)}"
	}

	network_interface {
		network = "default"

		access_config{

		}
	}

	tags = ["prometheus"]
}

resource "google_compute_instance" "postgres" {
	name = "postgres"
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
		 postgres_hosts = google_compute_instance.postgres.*.network_interface.0.access_config.0.nat_ip
		 prometheus_hosts = google_compute_instance.prometheus.*.network_interface.0.access_config.0.nat_ip
	   }
	)
 filename = "${path.module}/hosts"
}

resource "null_resource" "ansible_playbook_postgres" {
  depends_on = [
	local_file.ansible_host,
  ]
  provisioner "local-exec" {
    command = "ansible-playbook postgres/main.yaml"
  }
}

resource "null_resource" "ansible_playbook_prometheus" {
  depends_on = [
	local_file.ansible_host,
  ]
  provisioner "local-exec" {
    command = "ansible-playbook prometheus/main.yaml"
  }
}