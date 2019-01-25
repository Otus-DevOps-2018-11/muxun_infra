variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh acess"
}

variable private_key_path {
  description = "Path to private key"
}

variable disk_image {
  description = "Disk image"
}

variable zone {
  description = "zone of creating instance"
  default     = "europe-west1-b"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-1548414068"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-1548416636"
}
