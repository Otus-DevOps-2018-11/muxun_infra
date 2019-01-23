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

variable disk_image {
  description = "Disk image"
}

variable zone {
  description = "zone of creating instance"
  default     = "europe-west1-b"
}
