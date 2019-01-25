# muxun_infra
<details><summary>Домашнее задание № 3 bastion-host</summary><p>

---

Подключение к someinternalhost в одну команду с помощью ключа передачи терминала в ssh

`ssh -tA home@35.210.12.2 ssh 10.132.0.3`

---
Алиасы в ssh_config

Нужно использовать параметр ProxyCommand:
~/.ssh/config с использованием netcat 

```
Host bastion
        HostName 35.210.12.2
        User home

Host someinternalhost
        ProxyCommand ssh bastion nc -q0 10.132.0.3 22

```

~/.ssh/config с использованием ключа -W

```
Host bastion
        HostName 35.210.12.2
        User home

Host someinternalhost
        ProxyCommand ssh -A bastion -W 10.132.0.3:22
```

---

Конфигурация подключения


```
bastion_IP = 35.210.12.2
someinternalhost_IP = 10.132.0.3
```

</p></details>



<details><summary>Домашнее задание № 4 gcloud</summary><p>

создан инстанс из gcloud <br> 
установлены ruby и mongodb <br>
задеплоено реддит прриложение <br>


```
testapp_IP = 34.76.222.110
testapp_port = 9292
```
создание нового инстанса с 
параметром стартап-скрипта 

```
gcloud compute instances create reddit-app \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
----metadata-from-file startup-script=startup_script.sh

```


создание правила фаерволла для рандомного порта 8080(вместо 9292)

```
gcloud compute firewall-rules create another-default-puma-server \
 --network default  \
 --action allow  \
--direction ingress \
--rules tcp:8080  \
--source-ranges=0.0.0.0/0 \ 
--priority 1000  \
--target-tags puma-server
```


</p></details>

<details><summary>Домашнее задание № 5 packer</summary><p>
Packer - создание образов VM для различных провайдеров<br>

* установлен packer

```
cd ~
wget https://releases.hashicorp.com/packer/1.3.3/packer_1.3.3_linux_amd64.zip
unzip packer_1.3.3_linux_amd64.zip
sudo mv packer /usr/lib
rm packer_1.3.3_linux_amd64.zip

```

* произведена авторизация для аутентификации packer и terraform в GCP

```
gcloud auth application-default login

```

* создан шаблон для packer

```

 "builders": [
 {
 "type": "googlecompute",
 "project_id": "infra-226-212",
 "image_name": "reddit-base-{{timestamp}}",
 "image_family": "reddit-base",
 "source_image_family": "ubuntu-1604-lts",
 "zone": "europe-west1-b",
 "ssh_username": "appuser",
 "machine_type": "f1-micro"
 }
 ],
 "provisioners": [
 {
 "type": "shell",
 "script": "script/install_ruby.sh",
 "execute_command": "sudo {{.Path}}"
 },
 {
 "type": "shell",
 "script": "script/install_mongodb.sh",
 "execute_command": "sudo {{.Path}}"
 }
 ]
}

```

* на основе шаблона создан образ ubuntu1604 с предустановленными ruby и mongodb
* на основе образа создан инстанс и задеплоено приложение puma-server
* добавлено правило фаерволла для доступа к порту приложения 9292 инстанса reddit-app

* в шаблон добавлены параметры пользователя: обязательные для указания и указанные в самом шаблоне

```
{
   "variables": [
        {
        "project_id": null,
        "source_image_family": null,
        "machine_type": "f1-micro"
        }
        ],




  "builders": [
        {
        "type": "googlecompute",
        "project_id": "{{user `project_id`}}",
        "image_name": "reddit-base-{{timestamp}}",
        "image_family": "reddit-base",
        "source_image_family": "{{user `source_image_family`}}",
        "zone": "europe-west1-b",
        "ssh_username": "muxund",
        "machine_type": "{{user `machine_type`}}"
        }
        ],

 "provisioners": [
        {
        "type": "shell",
        "script": "script/install_ruby.sh",
        "execute_command": "sudo {{.Path}}"
        },

        {
        "type": "shell",
        "script": "script/install_mongodb.sh",
        "execute_command": "sudo {{.Path}}"
        }

        ]
}

```
*  созданы файлы переменных variables.json и variables.json.example с содержанием:

```
{

"project_id": "infra-226212",
"source_image_family": "ubuntu-1604-lts"

}

```

эти перменные будут вставляться в шаблон при создании образа с помощью команды:

```
packer build -var-file=variables.json ubuntu16.json
```

* добавлены параметры builder для GCP:
	- описание образа
	- размер и тип диска
	- название сети
	- теги

```
{
   "variables": 
	{
	"project_id": null,
	"source_image_family": null,
	"machine_type": "f1-micro",
	"image_description": "standart puma server on ubuntu",
	"disk_size": "10",
	"disk_type": "pd-standart",
	"network": "default",
	"tags": "reddit-app,http-server,https-server"
	}
	,




  "builders": [
	{
	"type": "googlecompute",
	"project_id": "{{user `project_id`}}",
	"image_name": "reddit-base-{{timestamp}}",
	"image_family": "reddit-base",
	"source_image_family": "{{user `source_image_family`}}",
	"zone": "europe-west1-b",
	"ssh_username": "muxund",
	"machine_type": "{{user `machine_type`}}",
	"image_description": "{{user `image_description`}}",
	"disk_size": "{{user `disk_size`}}",
	"disk_type": "{{user `disk_type`}}",
	"network": "{{user `network`}}",
	"tags": "{{user `tags`}}"

	}
	],

 "provisioners": [
	{
	"type": "shell",
	"script": "script/install_ruby.sh",
	"execute_command": "sudo {{.Path}}"
	},

	{
	"type": "shell",
	"script": "script/install_mongodb.sh",
	"execute_command": "sudo {{.Path}}"
	}

	]
}
```



</p></details>


<details><summary>Домашнее задание № 6 terraform-1</summary><p>

* установлен terraform

```
    wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip \ 
    && unzip terraform_0.11.11_linux_amd64.zip \
    && sudo mv terraform /usr/bin \
    && terraform --version
```

* установен  и проинициализирован провайде в файле main.tf

```
    13:53 $ terraform init
    
    Initializing provider plugins...
    - Checking for available provider plugins on https://releases.hashicorp.com...
    - Downloading plugin for provider "google" (1.4.0)...
    
    Terraform has been successfully initialized!
    
    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.
    
    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
```

* определty в файле main.tf ресурс для создания VM

```
    provider "google" {
            version = "1.4.0"
            project = "infra-226212"
            region = "europe-west1"
    }
    
    resource "google_compute_instance" "app" {
            name            = "reddit-app"
            machine_type    = "g1-small"
            zone            = "europe-west1-b"
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
```

* перед установкой изменений проверим корректность конфиурации

 
```
    15:10 $ terraform plan
    Refreshing Terraform state in-memory prior to plan...
    The refreshed state will be used to calculate this plan, but will not be
    persisted to local or remote state storage.
    
    
    ------------------------------------------------------------------------
    
    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
      + create
    
    Terraform will perform the following actions:
    
      + google_compute_instance.app
          id:                                                  <computed>
          boot_disk.#:                                         "1"
          boot_disk.0.auto_delete:                             "true"
          boot_disk.0.device_name:                             <computed>
          boot_disk.0.disk_encryption_key_sha256:              <computed>
          boot_disk.0.initialize_params.#:                     "1"
          boot_disk.0.initialize_params.0.image:               "reddit-base-1547821025"
          can_ip_forward:                                      "false"
          cpu_platform:                                        <computed>
          create_timeout:                                      "4"
          instance_id:                                         <computed>
          label_fingerprint:                                   <computed>
          machine_type:                                        "g1-small"
          metadata_fingerprint:                                <computed>
          name:                                                "reddit-app"
          network_interface.#:                                 "1"
          network_interface.0.access_config.#:                 "1"
          network_interface.0.access_config.0.assigned_nat_ip: <computed>
          network_interface.0.access_config.0.nat_ip:          <computed>
          network_interface.0.address:                         <computed>
          network_interface.0.name:                            <computed>
          network_interface.0.network:                         "default"
          network_interface.0.network_ip:                      <computed>
          network_interface.0.subnetwork_project:              <computed>
          project:                                             <computed>
          scheduling.#:                                        <computed>
          self_link:                                           <computed>
          tags_fingerprint:                                    <computed>
          zone:                                                "europe-west1-b"
    
    
    Plan: 1 to add, 0 to change, 0 to destroy.
    
    ------------------------------------------------------------------------
    
    Note: You didn't specify an "-out" parameter to save this plan, so Terraform
    can't guarantee that exactly these actions will be performed if
    "terraform apply" is subsequently run.
```
* создана инфраструктура 
```
    15:25 $ terraform apply 
    
    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
      + create
    
    Terraform will perform the following actions:
    
      + google_compute_instance.app
          id:                                                  <computed>
          boot_disk.#:                                         "1"
          boot_disk.0.auto_delete:                             "true"
          boot_disk.0.device_name:                             <computed>
          boot_disk.0.disk_encryption_key_sha256:              <computed>
          boot_disk.0.initialize_params.#:                     "1"
          boot_disk.0.initialize_params.0.image:               "reddit-base-1547821025"
          can_ip_forward:                                      "false"
          cpu_platform:                                        <computed>
          create_timeout:                                      "4"
          instance_id:                                         <computed>
          label_fingerprint:                                   <computed>
          machine_type:                                        "g1-small"
          metadata_fingerprint:                                <computed>
          name:                                                "reddit-app"
          network_interface.#:                                 "1"
          network_interface.0.access_config.#:                 "1"
          network_interface.0.access_config.0.assigned_nat_ip: <computed>
          network_interface.0.access_config.0.nat_ip:          <computed>
          network_interface.0.address:                         <computed>
          network_interface.0.name:                            <computed>
          network_interface.0.network:                         "default"
          network_interface.0.network_ip:                      <computed>
          network_interface.0.subnetwork_project:              <computed>
          project:                                             <computed>
          scheduling.#:                                        <computed>
          self_link:                                           <computed>
          tags_fingerprint:                                    <computed>
          zone:                                                "europe-west1-b"
    
    
    Plan: 1 to add, 0 to change, 0 to destroy.
    
    Do you want to perform these actions?
      Terraform will perform the actions described above.
      Only 'yes' will be accepted to approve.
    
      Enter a value: yes
    
    google_compute_instance.app: Creating...
      boot_disk.#:                                         "" => "1"
      boot_disk.0.auto_delete:                             "" => "true"
      boot_disk.0.device_name:                             "" => "<computed>"
      boot_disk.0.disk_encryption_key_sha256:              "" => "<computed>"
      boot_disk.0.initialize_params.#:                     "" => "1"
      boot_disk.0.initialize_params.0.image:               "" => "reddit-base-1547821025"
      can_ip_forward:                                      "" => "false"
      cpu_platform:                                        "" => "<computed>"
      create_timeout:                                      "" => "4"
      instance_id:                                         "" => "<computed>"
      label_fingerprint:                                   "" => "<computed>"
      machine_type:                                        "" => "g1-small"
      metadata_fingerprint:                                "" => "<computed>"
      name:                                                "" => "reddit-app"
      network_interface.#:                                 "" => "1"
      network_interface.0.access_config.#:                 "" => "1"
      network_interface.0.access_config.0.assigned_nat_ip: "" => "<computed>"
      network_interface.0.access_config.0.nat_ip:          "" => "<computed>"
      network_interface.0.address:                         "" => "<computed>"
      network_interface.0.name:                            "" => "<computed>"
      network_interface.0.network:                         "" => "default"
      network_interface.0.network_ip:                      "" => "<computed>"
      network_interface.0.subnetwork_project:              "" => "<computed>"
      project:                                             "" => "<computed>"
      scheduling.#:                                        "" => "<computed>"
      self_link:                                           "" => "<computed>"
      tags_fingerprint:                                    "" => "<computed>"
      zone:                                                "" => "europe-west1-b"
    google_compute_instance.app: Still creating... (10s elapsed)
    google_compute_instance.app: Creation complete after 16s (ID: reddit-app)
    
    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

* добавлен в секцию resources пункт metadata
```
    metadata {
                    ssh-keys = "muxund:${file("~/.ssh/id_rsa.pub")}"            }
```


* создадан  файл outputs.tf

```
    output "app_external_ip" {
     value = "${google_compute_instance.app.network_interface.0.access_config.0.assigned_nat_ip}"
    

```
* задано с помощью терраформа правило фаерволла
```
    resource "google_compute_firewall" "firewall_puma" {
            name    = "allow-puma-default"
            #название сети , в которой действует правило
            network = "default"
            # что разрешаем 
            allow {
                    protocol = "tcp"
                    ports    = ["9292"]
            }
            # откуда разрешаем доступ
            source_ranges = ["0.0.0.0/0"]
            # правила дл яинстансов с тегами
            target_tags = ["reddit-app"]
```

* дополен main.tf провижинами

```
    provisioner "file" {
    source = "files/puma.service"
    destination = "/tmp/puma.service"
    }
    
    provisioner "remote-exec" {
     script = "files/deploy.sh"
    }
```

* определены параметры подключения для провиженов
```
connection {
 type = "ssh"
 user = "muxund"
 agent = false
 private_key = "${file("~/.ssh/id_rsa")}"
 }
```

* созданы файлы с переменными и определены  variable

</p></details>

