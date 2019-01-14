# muxun_infra
muxun Infra repository
<details><summary>Домашнее задание №3</summary><p>

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



## Домашнее задание № 4

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
