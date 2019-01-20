# muxun_infra
<details><summary>Домашнее задание №3 bastion-host</summary><p>

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
Packer - создание образов VM для различных провайдеров
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



</p></details>

