
variable public_key_path {
  description = "Path to the public key used for ssh acess"
}


variable zone {
  description = "zone of creating instance"
  default     = "europe-west1-b"
}

variable app_disk_image {
	description = "Disk image for reddit app"
	default = "reddit-app-1548414068"

}

