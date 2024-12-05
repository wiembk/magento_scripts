#!/bin/bash

################## Exit the script if any command returns a non-zero status
# set -e

################## Function to handle errors
# handle_error() {
#   local exit_code="$?"
#   echo "Error occurred in line $BASH_LINENO: command '$BASH_COMMAND' exited with status $exit_code"
#   exit "$exit_code"
# }

################## Trap errors and execute the handle_error function
# trap 'handle_error' ERR

######################### Input funct° Parameters
BaseUrl='localhost'
DBHost='localhost'
DBName='magento2'
DBPassword='your_db_passwd'
AdminUser='admin'
AdminPassword='your_admin_passwd'
PublicKey='your_publicKey'
PrivateKey='your_privateKey'
OSUser='ubuntu'
Git_repo=''
Git_name=''


#################### Update and install Apache
echo -e "\e[32mUpdating the system and Installin Apache\e[0m"  # Green color
sudo apt update
sudo apt install apache2 -y
######################### Check Apache version and enable it
systemctl is-enabled apache2

####################### Install MariaDB and configure root user
echo -e "\e[32mInsalling and Configuring MariaDB\e[0m"  # Green color

sudo apt install -y software-properties-common
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mariadb.mirror.liquidtelecom.com/repo/10.4/ubuntu focal main'
sudo apt update && sudo apt install -y mariadb-server mariadb-client
sudo systemctl start mariadb
sudo systemctl enable mariadb

# sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DBPassword';"
# sudo mysql -e "SELECT user,authentication_string,plugin,host FROM mysql.user;"
sudo mysql -u root -p$DBPassword -e "CREATE USER 'magento2'@'localhost' IDENTIFIED BY '$DBPassword';"
sudo mysql -u root -p$DBPassword -e "GRANT ALL PRIVILEGES ON *.* TO 'magento2'@'localhost';"
sudo mysql -u root -p$DBPassword -e "FLUSH PRIVILEGES;"
sudo mysql -u magento2 -p$DBPassword -e "CREATE DATABASE magento2;"

################## Update and install PHP 7.4
echo -e "\e[32mInstalling and Configuring PHP\e[0m"  # Green color

sudo apt update
sudo apt install php7.4 libapache2-mod-php php-mysql -y
######################## Replace index.html with index.php and vice versa
sudo sed -i 's/DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm/DirectoryIndex index.php index.cgi index.pl index.html index.xhtml index.htm/g' /etc/apache2/mods-enabled/dir.conf
########################" Install required PHP modules
sudo apt install php7.4-mbstring -y
sudo phpenmod mbstring
sudo a2enmod rewrite
sudo apt install php7.4-bcmath php7.4-intl php7.4-soap php7.4-zip php7.4-gd php7.4-json php7.4-curl php7.4-cli php7.4-xml php7.4-xmlrpc php7.4-gmp php7.4-common -y
sudo systemctl reload apache2
################## Update PHP configuration
sudo sed -i 's/max_execution_time = 30/max_execution_time = 18000/g' /etc/php/7.4/cli/php.ini
sudo sed -i 's/max_input_time = 60/max_input_time = 1800/g' /etc/php/7.4/cli/php.ini
sudo sed -i 's/memory_limit = -1/memory_limit = 2G/g' /etc/php/7.4/cli/php.ini

############### Install elasticsearch
echo -e "\e[32mInstalling and Configuring ElasticSearch\e[0m"  # Green color

sudo apt install openjdk-17-jdk -y
sudo apt install curl -y
sudo curl -sSfL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --no-default-keyring --keyring=gnupg-ring:/etc/apt/trusted.gpg.d/magento.gpg --import
sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'
sudo chmod 666 /etc/apt/trusted.gpg.d/magento.gpg
sudo apt update
sudo apt install elasticsearch
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
sudo sed -i 's/#node.name/node.name/g' /etc/elasticsearch/elasticsearch.yml
sudo sed -i 's/#cluster.name/cluster.name/g' /etc/elasticsearch/elasticsearch.yml
sudo sed -i 's/#network.host: 192.168.0.1/network.host: 127.0.0.1/g' /etc/elasticsearch/elasticsearch.yml
sudo sed -i 's/#http.port: 9200/http.port: 9200/g' /etc/elasticsearch/elasticsearch.yml
sudo systemctl daemon-reload
sudo systemctl restart elasticsearch.service
curl -X GET 'http://localhost:9200'

################### install composer
echo -e "\e[32mInstalling Composer\e[0m"  # Green color

cd /var/www/html/
sudo wget https://getcomposer.org/installer -O composer-setup.php
sudo php composer-setup.php --install-dir=/usr/bin --filename=composer
composer

################# Install Magento
echo -e "\e[32mInstalling Magento\e[0m"  # Green color

sudo chown -R ${OSUser}:${OSUser} /var/www/html/
sudo -u ${OSUser} composer --no-interaction config --global http-basic.repo.magento.com "$PublicKey" "$PrivateKey"
git clone $Git_repo
cd $Git_name
sudo -u ${OSUser} composer config --global allow-plugins true
sudo -u ${OSUser} composer install
echo -e "\e[32monfiguring Permissions\e[0m"  # Green color
sudo usermod -aG www-data ${OSUser}
sudo find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
sudo find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
sudo chown -R ${OSUser}:www-data .
sudo chmod u+x bin/magento
echo -e "\e[32mConfiguring Magento\e[0m"  # Green color

sudo php bin/magento setup:install --base-url=http://${BaseUrl} --db-host=${DBHost} --db-name=${DBName} --db-user=${DBName} --db-password=${DBPassword} --admin-firstname=admin --admin-lastname=admin --admin-email=admin@admin.com --admin-user=${AdminUser} --admin-password=${AdminPassword} --language=en_US --currency=USD --timezone=America/Chicago --backend-frontname=admin --search-engine=elasticsearch7 --elasticsearch-host=localhost --elasticsearch-port=9200

################# configure Apache
echo -e "\e[32mConfiguring Apache\e[0m"  # Green color

cat <<EOF | sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/$Git_name/pub

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory "/var/www/html">
        AllowOverride all
    </Directory>
</VirtualHost>
EOF
sudo systemctl restart apache2
sudo chmod -R 777 var pub/static generated generated/
sudo php bin/magento module:disable Magento_TwoFactorAuth
echo -e "\e[32mFlushing The Cache\e[0m"  # Green color

sudo php bin/magento cache:flush
sudo php bin/magento cache:clean

echo "***************Magento 2 setup completed.***********"
sudo su ${OSUser}
