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

* определил в файле main.tf ресурс для создания VM

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



<details><summary> Домашнее задание № 7 terraform-2</summary>
<p>

* создано правило фаерволла для ssh порта

```
#====FIREWALL SSH====
resource "google_compute_firewall" "firewall_ssh" {
  name    = "default-allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

```

* в терраформ стэйт импортироване правило ssh портя, объявленное ранее

* создана неявная зависимость ресурсов внешнего ip и  ip инстанса

```

#====INSTANCE====
resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  /....
}

#====ADDRESS====
resource "google_compute_address" "app_ip" {
  name   = "reddit-app-ip"
}


```

* в packer созданы шаблоны для подготовки образов app и db

* конфигурация terraform разбита на несколько частей 
	-app.tf
	-db.tf
	-main.tf
	-vpc.tf

* на основе предыдущих конфигураций созданы модули app db vpc

```
rovider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "app" {
  source          = "../modules/app"
  public_key_path = "${var.public_key_path}"
  zone            = "${var.zone}"
  app_disk_image  = "${var.app_disk_image}"
}

module "db" {
  source          = "../modules/db"
  public_key_path = "${var.public_key_path}"
  zone            = "${var.zone}"
  db_disk_image   = "${var.db_disk_image}"
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["182.126.72.77/32"]
}


```

* проверена работ по параметризации source_range  модуля vpc c помощью телнета

* созданы конфигурации для окружений stage и prod с раздичными параметрами vpc

* созданы 2 экземпляра storage-backet

```
provider "google" {
        version = "1.4.0"
        project = "${var.project}"
        region  = "${var.region}"
}


module "storage-bucket" {
        source = "SweetOps/storage-bucket/goog$
        version = "0.1.1"

        name = ["st_bucket1","st-bucket2"]

}

output storage-bucket_url {
        value = "${module.storage-bucket.url}"
}



```
</p></details>


<details><summary> Домашнее задание № 8 ansible-1</summary>
<p>

* ansible установлен с помощью apt install
* запущено stage окружение в терраформе и проверена доступность ssh telnetom
* создан inventory файл для хоста app и проверена доступность с помощью пинг

```
✔ ~/otus/hw9/muxun_infra/ansible [ansible-1 L|…1] 
13:50 $ ansible appserver -i ./inventory -m ping
appserver | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}

```

* добавлен хост с базой данных в инвентори
* создан и параметрезиован ansible.cfg

```
[defaults]
inventory = ./inventory
remote_user = muxund
private_key_file = ~/.ssh/id_rsa
host_key_checking = False
retry_files_enabled = False
```
* проверен модуль ping с параметрами

```
✔ ~/otus/hw9/muxun_infra/ansible [ansible-1 L|✚ 1…1] 
14:20 $ ansible appserver -m ping
appserver | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
✔ ~/otus/hw9/muxun_infra/ansible [ansible-1 L|✚ 1…1] 
14:21 $ ansible dbserver -m ping
dbserver | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}


```
* проверены ad-hoc команды

```
4:24 $ ansible dbserver -m command -a uptime
dbserver | SUCCESS | rc=0 >>
 11:28:28 up 55 min,  1 user,  load average: 0.00, 0.00, 0.00

✔ ~/otus/hw9/muxun_infra/ansible [ansible-1 L|✔] 
14:28 $ ansible dbserver -m command -a ifconfig
dbserver | SUCCESS | rc=0 >>
ens4      Link encap:Ethernet  HWaddr 42:01:0a:84:00:28  
          inet addr:10.132.0.40  Bcast:10.132.0.40  Mask:255.255.255.255
          inet6 addr: fe80::4001:aff:fe84:28/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1460  Metric:1
          RX packets:1678 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1552 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1996685 (1.9 MB)  TX bytes:162152 (162.1 KB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

* создан inventory в формате yml и проверен

```
15:13 $ ansible all -m ping -i inventory.yaml 
dbserver | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
appserver | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```

* проверены модули systemd и service

```
✔ ~/otus/hw9/muxun_infra/ansible [ansible-1 L|✚ 1…1] 
15:25 $ ansible db -m service -a name=mongod
dbserver | SUCCESS => {
    "changed": false, 
    "name": "mongod", 
    "status": {
        "ActiveEnterTimestamp": "Sat 2019-01-26 10:32:48 UTC", 
        "ActiveEnterTimestampMonotonic": "13819239", 
        "ActiveExitTimestampMonotonic": "0", 
        "ActiveState": "active", 
        "After": "sysinit.target basic.target network.target systemd-journald.socket system.slice", 
        "AllowIsolate": "no", 
        "AmbientCapabilities": "0", 
        "AssertResult": "yes", 
        "AssertTimestamp": "Sat 2019-01-26 10:32:48 UTC", 
        "AssertTimestampMonotonic": "13818217", 
        "Before": "multi-user.target shutdown.target", 
        "BlockIOAccounting": "no", 
        "BlockIOWeight": "18446744073709551615",
.......................

```

* создан playbook с заданием деплоя приложения

```
✔ ~/otus/hw9/muxun_infra/ansible [ansible-1 L|✚ 1…2] 
16:13 $ ansible-playbook clone.yml 

PLAY [Clone] ********************************************************************************

TASK [Gathering Facts] **********************************************************************
ok: [appserver]

TASK [Clone repo] ***************************************************************************
changed: [appserver]

PLAY RECAP **********************************************************************************
appserver      
```



</p></details>


<details><summary> Домашнее задание № 9 ansible-2</summary>
<p>

* создан playbook для управления конфигурациями и деплоя приложения
  - сценарии для каждого хоста
  - шаблоны конфиг файлов
  - сделан пробный прогон плэйбука
  - введены хэндлеры \ таски для деплоя приложения
  - плэйбук применён

```

✔ ~/otus/hw10/muxun_infra/ansible [ansible-2|✔] 
10:55 $ cat reddit_app_one_play.yml 
---
- name: Config host and deploy application # Описание сценария
  hosts: all # Хосты, на которых выполятся таски
  vars:
    mongo_bind_ip: 0.0.0.0 # переменная задается в vars
    db_host: 10.132.0.48


  tasks: # блок тасков(заданий)
    - name: меняю конфиг монги на db 
      become: true # выполняем задание от рута
      template:
        src:  templates/mongod.conf.j2 # путь до шаблона
        dest: /etc/mongod.conf # целевой путь на удаленном хосте
        mode: 0644  # права на файл
      tags: db-tag   # тэги задания 
      notify: restart mongod

    - name: устанавливаю пума юнит на app
      become: true
      copy:
        src:   files/puma.service
        dest: /etc/systemd/system/puma.service
      tags: app-tag
      notify: reload puma

    - name: добавляю конфиг подключения к бд на app
      template:
        src: templates/db_config.j2
        dest: /home/muxund/db_config
      tags: app-tag

    - name: enable puma для app
      become: true
      systemd: name=puma enabled=yes
      tags: app-tag

    - name: граблю приложение из гита на апп
      git:
        repo: 'https://github.com/express42/reddit.git'
        dest: /home/muxund/reddit
        version: monolith # <-- Указываем нужную ветку
      #tags: deploy-tag
      tags: app-tag
      notify: reload puma

    - name: инсталирую bundle на app
      bundler:
        state: present
        chdir: /home/muxund/reddit # <-- В какой директории выполнить команду bundle
     # tags: deploy-tag 
      tags: app-tag  
     

  handlers:
  - name: restart mongod
    become: true
    service: name=mongod state=restarted
    
  - name: reload puma
    become: true
    service: name=puma state=restarted 


```

<img src="https://s3.us-west-2.amazonaws.com/secure.notion-static.com/7a52878a-ad17-44a7-a307-10d54c0b7495/oneplayonescen.png?AWSAccessKeyId=ASIAT73L2G45HOBQHFM6&Expires=1548835308&Signature=F2GHKWsHutLGxyBqUyVon4JTu%2Bk%3D&x-amz-security-token=FQoGZXIvYXdzEBAaDKFv2hlRTRvWbXo8GiK3A4MOL4eBpO8a%2FMtwYA0RV3ELQOMwXpp%2BRTO6SZGg7Dd3GpB3kT2WNJcbZ7%2BS0SjBYAcmUW7tSvxbYz%2B1EA6GC3XXdGpPngpdgzCBVAA%2BjGfJX1br9c17ZjNYlXMmCnH6wFFtRkyZN8Kyy2OWPxmZ%2F7ZQo4aga6gFpN%2BmpQOIj0iLLiGW8vIcWb6ePYuhZeFd%2FeSKqSNNvvVACO%2F7O1KK157%2FU5l2W7fCMpXgE%2B4MNrRZbgHG3n8LSajbXTf5ttzvCPW%2BGM2FN2B658vQiiR1eDxVLmnW1EehTi7Y4ii0ABFAVA2jS0vz20uxYp1QxGo8nkJ1TaQTpDPplWsH9RKqG0PrYpegCERzc7yN7lkx%2Ba%2FXt0dXRku%2FYoNg467syn6gpoYgXE43Ip5EmZC2%2FQuLxEssZYo%2F2V8HOUm%2BLi5I72kCbplz8qd29bskxPu%2F95bLL8WYjtwNs1byHwhr6EcLC9isVRNm%2F4%2BuMqqoLHL7UV0NSfTrnHSTcQwnUeYoMbn9S1SJzYg10p10FFHdAS0CXVAbPAN%2B%2FGH%2F3VH16TfSDkB8eQ6ZJENIlCxkNv3IuG6BYK%2B7f3a%2FS5Qosd6%2F4gU%3D"></img>



* создан плэйбук с несколькими сценариями
* добавлен по образцу сценарий для деплоя

```

✔ ~/otus/hw10/muxun_infra/ansible [ansible-2|✔] 
10:55 $ cat reddit_app_multiple_plays.yml 
---
- name: Конфигурируем mongodb хост
  hosts: db
  tags: db-tag
  become: true
  vars:
    mongo_bind_ip: 0.0.0.0
  tasks:
    - name: Меняю конфиг монги на db 
      become: true
      template:
        src:  templates/mongod.conf.j2
        dest: /etc/mongod.conf
        mode: 0644
      tags: db-tag 
      notify: restart mongod
  handlers:
    - name: restart mongod
      service: name=mongod state=restarted 
    

- name: Конфигурируем хост app
  hosts: app
  tags: app-tag
  become: true
  vars:
    db_host: 10.132.0.50
  tasks:
    - name: Копируем юнит пума-сервис на app
      copy:
        src:   files/puma.service
        dest: /etc/systemd/system/puma.service
      notify: reload puma

    - name: Добавляем конфиг подключения к бд на app
      template:
        src: templates/db_config.j2
        dest: /home/muxund/db_config
        owner: muxund
        group: muxund

    - name: enable puma для app
      systemd: name=puma enabled=yes

  handlers:    
  - name: reload puma
    service: name=puma state=restarted 


- name: Деплой приложухи
  hosts: app
  tags: deploy-tag
  become: true
  tasks:
    - name: граблю приложение из гита на апп
      git:
        repo: 'https://github.com/express42/reddit.git'
        dest: /home/muxund/reddit
        version: monolith 
      notify: restart puma

    - name: инсталирую bundle на app
      bundler:
        state: present
        chdir: /home/muxund/reddit 

  handlers:
    - name: restart puma
      become: true
      systemd: name=puma state=restarted

```

<img src="https://s3.us-west-2.amazonaws.com/secure.notion-static.com/ecb50d66-3a42-496f-952c-1a976b76c883/multiplecneario.png?AWSAccessKeyId=ASIAT73L2G45BXVWHNL4&Expires=1548835300&Signature=B9Vv3iHADpVwnGxmTj3CufCoLSM%3D&x-amz-security-token=FQoGZXIvYXdzEBAaDBPLlI9NEA6JI8FadyK3A%2FOMK22s5I%2F6Mtck2ikT9Ssgwov4doSWwEkbYb5GeNn9SxdgeqOOQEFGTOfocKiWYtpuWyahhu6GAzM6dae0cnloA%2BQ0oE6Q1lKHCiz%2B0n6RWV%2BGTtLQNh%2BsIDy819Ih6skaKqxEVxWNTqXapf7EPYVEvzJTAP1YYrI5O9s3G9uOGSjURrb4mWyELOjydYkqmufvnyCDyhCHOLmLTU38i3BQuvBY12Yrkh5dIuAxetEOTS%2B5GFaWNd9QzBlHKOjLGJ4ie9MTojw2OpFjd3neuXBmw4RfsCiTJPlPloX%2FShXih8rPsesUu4mf7tSMq9rKbIVxmNR96tptwNwPNs5vTzSGL%2BX3m9LvZLGWQIHKmTRlcQ%2BuM8DEahSsW8ObYJc5d1yDTJw9J9iuIAVhOjht9t3dAcIxZ5fmxAoyo6g97mS0CIamTv8KJWiCbSRvPAaXueezbESxA6zUBJ7DZ704FsWVGfXBBSNbraN4NtUlqhHbCQ%2FsF3hv4on2fqMZOVE4hwmsulO0We8%2FCkbRbNB10dMD9CSDkdYuKtzlES8zf1fBTapdu8vR4WEB0pfwDR0zm4746hrtZjooluu%2F4gU%3D"></img>

* на основе предыдущих наработок создано несколько плэйбуков и объеденены с помощью import_playbook в site.yml

```

✔ ~/otus/hw10/muxun_infra/ansible [ansible-2|✔] 
11:06 $ cat app.yml db.yml deploy.yml
---
- name: Конфигурируем хост app
  hosts: app
  become: true
  vars:
    db_host: 10.132.15.194
  tasks:
    - name: Копируем юнит пума-сервис на app
      copy:
        src:   files/puma.service
        dest: /etc/systemd/system/puma.service
      notify: reload puma

    - name: Добавляем конфиг подключения к бд на app
      template:
        src: templates/db_config.j2
        dest: /home/muxund/db_config
        owner: muxund
        group: muxund

    - name: enable puma для app
      systemd: name=puma enabled=yes

  handlers:
  - name: reload puma
    service: name=puma state=restarted

---
- name: Конфигурируем mongodb хост
  hosts: db
  become: true
  vars:
    mongo_bind_ip: 0.0.0.0

  tasks:
    - name: Меняю конфиг монги на db
      become: true
      template:
        src:  templates/mongod.conf.j2
        dest: /etc/mongod.conf
        mode: 0644
      notify: restart mongod

  handlers:
    - name: restart mongod
      service: name=mongod state=restarted


---

- name: Деплой приложухи
  hosts: app
  tasks:
    - name: граблю приложение из гита на апп
      git:
        repo: 'https://github.com/express42/reddit.git'
        dest: /home/muxund/reddit
        version: monolith
      notify: restart puma

    - name: инсталирую bundle на app
      bundler:
        state: present
        chdir: /home/muxund/reddit

  handlers:
    - name: restart puma
      become: true
      systemd: name=puma state=restarted


```

<img src="https://s3.us-west-2.amazonaws.com/secure.notion-static.com/b4d5de0a-a1a3-4a00-95b0-c3c50b9b200a/siteplaybok.png?AWSAccessKeyId=ASIAT73L2G45NKA4IGFP&Expires=1548835706&Signature=7v4F63MzyiUbabM5V003%2FyAJT%2F8%3D&x-amz-security-token=FQoGZXIvYXdzEBAaDLtslAGySyHccT%2B42yK3Ay%2FjbK43hItaoZ%2FyzEUhWLAu2mTVRPTHPWU6C7U0S5BIn81P%2BmFfzU%2BnqK5gwVy6mvaXcTlMeRhB1gdQTy1TlBbIK%2BBcEiZGnYCp5hb3ae9Q7aTzyQb4C0i7kMbA0EqfOSG7oXw%2BYYAt%2BoHBNNUDSZieI4UA1IGyQMm0i7hB8tChfeKOV73RwWnPqGPgDF7IEgmQxzvNfWKTu7ZVH13SlPvJIkGmclrU%2BRU14dkzW0v2aZMN07JVPI1Sn7O5QJEIN%2BQccMgArPZchRg6y%2FQs6INIEcb%2FMCeci0%2BHm%2FaANwn1rhDW2fRxs8a7ZN53%2Bv3xQMCve1lrhL2q3K%2FdiDIWRjdNWP0hUZ66G7W7iWvuFjQWsSAE8MdgjCf%2BM8O0YFc00W4C5shivwNnVVcsExuWJiXVYSqjIv7S1HxZjoV0Dt7ZMHCOCaYn0bmpLBXNVEhDUulmVeIjc3GA1vzq8NjBRT0%2FaIs0KMOoQX9Wu4mltcKqNzbGIGGdtEDD8eD7JRcbZMA3bhe2JhZ8lqPwzOYl3dem7VhbxcovBHZS%2FsRjCaW1hmG5u2EUNPeXMymS%2F%2BPcUeA147qaIiUo5vG%2F4gU%3D"></img>


* созданы ansible сценарии для провиженов

```

 ~/otus/hw10/muxun_infra/ansible [ansible-2|✔] 
11:07 $ cat packer_*
---
- name: Install Ruby && Bundler
  hosts: all
  become: true
  tasks:
  # Установим в цикле все зависимости
  - name: Install ruby and rubygems and required packages
    apt: "name={{ item }} state=present"
    with_items:
      - ruby-full
      - ruby-bundler
      - build-essential
---
- name: Install MongoDB 3.2
  hosts: all
  become: true
  tasks:
  # Добавим ключ репозитория для последующей работы с ним
  - name: Add APT key
    apt_key:
      id: EA312927
      keyserver: keyserver.ubuntu.com

  # Подключаем репозиторий с пакетами mongodb
  - name: Add APT repository
    apt_repository:
      repo: deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse
      state: present

  # Выполним установку пакета
  - name: Install mongodb package
    apt:
      name: mongodb-org
      state: present

  # Включаем сервис
  - name: Configure service supervisor
    systemd:
      name: mongod
      enabled: yes


```

* и созданы новые образы app и db
* на основе образов пересоздана stage инфраструктура
* применен ansible-playbook

<img src="https://s3.us-west-2.amazonaws.com/secure.notion-static.com/60cf0422-9826-44e2-835f-0f242c533a62/.png?AWSAccessKeyId=ASIAT73L2G45EHF4HKSE&Expires=1548836023&Signature=cNX2LMgQUjsmoS4JSVfPNrmY4l4%3D&x-amz-security-token=FQoGZXIvYXdzEBAaDCJ4eBBhbRochVGzeiK3A3YLk3NUWJaiHPwlFGWUlXkya6SjR12CgmtxKyGvOeQqJ%2FKhaiJnUNDIwyLhKEYr93AoMI0rqTTeoV9Hv%2ByZEX2xiqu9d4%2FucQNCjc%2FPHlz926x8Z2TMi%2BgR%2FaQfTDz81hH2lagTFPxXqdT7QmE1QQOva0MndDnlAYoSbnwnGtMRSaWM1kaIX1tG8aP4FIi2ZreRGYzrZHb8vJRHdJw86%2Flw8EwzIin041LPVe8u9o0Cay7Xim%2BJtT5qPHQkTmzrOtEB4JVns0%2F%2F1m%2FJs7T2Eg7WdHqM5aeDWsiiPICxBVXk0f4kSKbcXOcsyznKSuSZC6gZtQX61UY7trKc%2BhhylbcBN8V5ufOz0%2BzWemldAIsaeK8lneuoYuMc4jycRAd8IK48Tnl1vWpDLcWtWgFeJjckryFkxHUmoK6FylRDEpAIfRrEPxKy8rhc8MSYW%2B3lqP4As1KawEGMIVyUAp5GIRE3K15ylKb7SWdEDiRUZC%2FyYb0%2FXL7UQEfDicbhalJwDf1LZnUt8NAEKRfzrSMdMRv%2BVS9Pw8VMSIhzvwOFpnPehr6LYWIp8bhTzmf6FO03%2B3zeL%2BOT6zgo8tq%2F4gU%3D"></img>



</p>
</details>


 
<details><summary> Домашнее задание № 10 ansible-3 </summary>
<p>
 * созданы роли для app и db, протестирован playbook
  <img src="https://s3.us-west-2.amazonaws.com/secure.notion-static.com/b7b8855c-f5ba-4221-92c6-a24daeb3c131/ansible-rolesdeploying.png?AWSAccessKeyId=ASIAT73L2G45HG2B6BHH&Expires=1549439120&Signature=c610Li5Wmvr%2BZQARz%2FBBn7As7y0%3D&x-amz-security-token=FQoGZXIvYXdzELP%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaDJHQ5%2Fdu0QjGY3n3sCK3A5HXafhgWwDmKC0SdRBW1u%2Fuq9tc20qDDbeVbWBRibid8d94RLR5yuZBPhsiEKi6ekJdd1hlnP6eNc5S9%2FBzy0cok32EXSz7ATX8vDxoLvVXM2RQziyAWyvfnoCyq384E3zzDJY9naP6GC3vc1qeo0ogAoVi5hrH2GiDilcQl%2BWQddu8WMPKElDMtbwZFZjrBUhCaoCCGJokTuKP4cxXUgiJyqokj4BeV3RGpETeTOiLFiwx3cqfmHa4KeYAEFIV7ddzZ18Q3cu6WZnJ3nB01GHlXT9N2u4EmFECe6yIupXDCgdbqPHEQw68eLdaoPX0cSZ2LS6OEBOJHv%2BuCO36JnyfpU29bAUa9LiPgxRt2d%2B%2FbxaFopIOJCGx4u%2BAr0YdobbEhW9a0tGs3S88FJt4lyM9XSNp2cWbcBeyjSJURMRhtw3Ar7o22h%2BbzEnhsB%2F6G8AYII3uhzX1yPdMEuarP1XAo3Hjk%2FTSTQEL5k8yd0kvJgHb2M9GB9sJ74YHlJbPAyrrw8FmvOitsMW9ExE3KgLtRo8En9pthktqW1u8S4KMzuFPqHU3Mue%2BaCKFZz2eXdFVYhiC4Uwo9djj4gU%3D"></img>

 * созданы окружения prod и stage c различными inventory файлами и group_vars
 * проведена организация директории ansible с выделением playbooks, roles, environments
 * проверены playbooks на stage и prod окружения

 - stage
 <img src="https://s3.us-west-2.amazonaws.com/secure.notion-static.com/968b263c-7340-4819-a0fa-ff615aaa92d3/grandplaybookansible.png?AWSAccessKeyId=ASIAT73L2G45KHQDLEGM&Expires=1549439391&Signature=OtHFhnZziRC8zxKggvpaASk9jHc%3D&x-amz-security-token=FQoGZXIvYXdzELT%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaDKCY5cxB7OL%2FLmfyUSK3A%2Bgz4jyHNlrwd%2Boo85PJWm%2Bjxi3Lo8hBZU5IUHXIm0985REOfCN8xMuwu85BxzftWER91LfbEJhsBWhiggLnDHEEFlVEOeIBagZaXNaQUHqhcngPg8Km04YEB8hme1M6dysaxr%2FXU8EZuMuKihUlM5foKSWTJ2MbRP9Kd0fmI8A4VPXTBYlTPYhJAiKMK7puSl51JDtVSNCp2gPmCQjdzOZYFHfptaPGSSpE8%2Bu%2Bg92Ne003XgdKoTcmS74gLYZ5FWorfsD4JXJ5IlPbAzDmr%2FwNJTVWZwt83hqkhH0bKv2asNSOXyDa7D59R6ukxYi9j1fIZrezYTINrCjeJ1fv4p%2Bs%2F2RsLv4YQ%2Bs9EVnjF%2B5tpxyyXWsFY3vI6EYDvk7jZtLPatRw6oKAoNpJ1Lk6jr94bne%2BywlGfeQoi2LcjDSP5PqLrao1C12dVsjn224KcLg3nCStDX94Oc6wHvSOjA4AHaUFWaW72AB2fFl3mf9CVskfVQ8%2BozDdH53RXpncbym0JrhirXliOr3ag5LwWByJfxKb6n30Eo4ETAR%2B84KW2y1UDvPQa55BW2TrmSDf%2BccZwwbajJAord%2Fj4gU%3D"></img>

 - prod
<img src="https://s3.us-west-2.amazonaws.com/secure.notion-static.com/ec79141c-ad4d-4d06-9737-484e513ada6b/prodgrandansible.png?AWSAccessKeyId=ASIAT73L2G45KSE4NB7B&Expires=1549439762&Signature=InNjadZpnLEuxMh84UVpC9OITDs%3D&x-amz-security-token=FQoGZXIvYXdzELT%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaDJk3Wg44oWFA54SwniK3A2JTdXTl3gkOjYATnq38FVcfgIMxvCpulokSC%2FCfoef%2Fh40QMB1jSL3ff%2B89N1xDUKYYxYmr95L4sQVL38uAMQ7gA%2B0QxgJNeqiUPKxnP67JIroNticGp5Ob7qbotK9przAoW3HY73xVafMP7OrXv60EplgDYLHPYWmQe8JUPo1fIvWnkEHrxgHBIh76wbCKKYIicLT%2FFcMjs8p%2B7SWoVUpnkg2OhU5mDv5puZPECWxCnltjXc16HJWkk7amGXhGEaKNmALj%2BDhoePKq8BW5YNNuRPI%2FU8d%2BHma%2B1OT3MafuBj3GJiNbe8AoInRPO5%2B0zOlR%2B%2BdDbsk2ZcyWN7emuaQJ8xJbutaJ5QXqTXBKHFxDT12mrbwkOoYoq3R0jxvSPtCkR%2BMIsIVh0aUiKheUf%2FXhhGRcK1Jli0iH92%2FNqMSKbLwbsciayc8ZeYVI1P1JooKMzVsAXRgkI%2FVBaSA%2FQ0JaKbaZzyc2%2BBGDrRYh191r9HPGxWDfFIxPdquiPsfSlmNC8A6wNE0Q0OsXiuYGrzWv5FSoQmjQFlaMSr8HzUAPRUSv8i9bNCv3Gdtdp3ZS9PGa9GGBIa4o6eDj4gU%3D"></img>

 * в роли добавлена роль jdauphant.nginx из ansible-galaxy
 * в конфиг terraform добавлено правило фаерволла на доступ по 80 порту
 * проверена работа на stage окружении с применением роли nginx 
   в процессе работы столкнулся с проблемой dpkg\lock для тасков роли nginx
   проблемы решал вручную удалением локов и перезапуском плэйбука

<img src="https://s3.us-west-2.amazonaws.com/secure.notion-static.com/51962773-0b23-4952-ab0b-886b2df0a551/deploywithnginx.png?AWSAccessKeyId=ASIAT73L2G45NKZQGLHA&Expires=1549439558&Signature=Ct69t96POXfrgIz%2BmPZ7AD8npHk%3D&x-amz-security-token=FQoGZXIvYXdzELT%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaDKDvW23Pv5OQV80kzyK3A2Non4lmcT59OgiuZ03cMsf5nbJycKdAtGml%2FuvPDXFvtYyutWUao%2Bmc1Rv4Byogjf0NGu0m2pCmg1eiZpbkOnMK9v8vcL8GUnCxnkZWzigeKpFdWq4wYgKYsB6rs4cApch9B1CVF82esLoatlqgOEU%2BeZQqX21NIBdQyvRfvLpg70yfGyItDVDfSNnTPurM31RJ3AumUL1JQvcS2zTksCPOeNxNk66GV0gYjH4hKYt3TL2%2B36ytmOC2MG4GvPbzfy032kJFmvjj6Fj5ZoRcywb1cWr1Ii3ZWxKK2QO1%2FEvkMrnfI7%2B8TajgpP9LcsM%2FQ2usEyZWgiLXiPVY9OnNqFihfYerxJjiuDCRkHkZaubatC0QqCVF7TylcGeFxPriQynPCOsZJHI9LB%2BA63lgTJYckRDKtKuVRFU9huTqfulQFyUuVlr0NV%2FCL6v6VO2zzFqUrnbUJ87Xsp5yKRBr3gjvwHsa48H9oG6by5GTKIb1HLl3icx6NPeCP9oxOZEZpR8XJ%2FF3C1DP0DKjPbtgwJXaTkG5ZRYijHPc8tNvF5qKpRfmox95bghBQfn37VMoHg6tNe4nkXIouePj4gU%3D"></img>

 * использован ansible-vault для создания зашифрованного списка юзеров и паролей

</p>
</details>

<details><summary> Домашнее задание % 11 ansible-4 </summary>
<p>
	
* установлен vagrant
* в Vagrantfile описаны два инстанса app и db
* подняты, проверены  и уничтожены VM
* добавлены провижены ansible в Vagrantfile, определены переменные
* создан дополнительный playbook base.yml для установки python 
* доработаны роли и созданы файлы тасков для db и app для установки и настройки конфигурации приложения
* параметризиованы роли {{ deploy_user}}
* переопределены переменные
* в процессе проверки не получилось достучаться с app до db по порту 27017, при этом ip_tables ничего не блокировал.
 проблему решил заменой праметра mongo_bind_ip c 127.0.0.1 на 0.0.0.0 .С такими параметрами заработало.
* уничтожены и восстановлены для проверки VM
* установлены virtualenv\ в нем ansible molecule testinfra
* проинициализированно molecule окружение в ansible роли db
* созданы тестовые машины и протестированы роли
* дописан тест на проверку binding порта 27017
<img src="https://raw.githubusercontent.com/muxun/muxun.github.io/master/testinfra%20socke.png"></img>

</p></details>

