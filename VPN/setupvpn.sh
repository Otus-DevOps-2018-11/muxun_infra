!/bin/bash
sudo echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.4.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 0C49F3730359A14518585931BC711F9BA15703C6
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
sudo apt-get  update
sudo apt-get  upgrade
sudo apt-get  install mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
sudo wget https://github.com/pritunl/pritunl/releases/download/1.29.1923.80/pritunl_1.29.1923.80-0ubuntu1.xenial_amd64.deb
sudo dpkg -i pritunl_1.29.1923.80-0ubuntu1.xenial_amd64.deb
sudo systemctl enable pritunl
sudo systemctl start pritunl
