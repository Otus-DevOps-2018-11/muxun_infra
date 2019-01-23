provider "google" {
	version = "1.4.0"
	project = "infra-226212"
	region = "europe-west1"
}

resource "google_compute_instance" "app" {
	name 		= "reddit-app"
	machine_type 	= "g1-small"
	zone		= "europe-west1-b"
	#определение загрузочного диска
	boot_disk {
		initialize_params {
			image = "reddit-base-1547821025"
		}
	}
	#определение сетевого интерфейса
	network_interface {
		# сеть , к которой присоеденить интерфейс
		network = "default"
		# использовать ephimeral IP для доступа в интернет
		access_config {}
	}

}
