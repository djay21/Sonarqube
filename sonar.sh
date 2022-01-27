sudo yum -y install epel-release
sudo yum -y update
wget --no-cookies --no-check-certificate --header "Cookie:oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm"
sudo yum -y localinstall jdk-8u131-linux-x64.rpm
java -version
sysctl vm.max_map_count
sysctl fs.file-max
ulimit -n
ulimit -u
sudo yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm -y
sudo yum install postgresql11-server -y
sudo /usr/pgsql-11/bin/postgresql-11-setup initdb

sudo sed -i -e 's/peer/trust/g' /var/lib/pgsql/11/data/pg_hba.conf
sudo sed -i -e 's/ident/md5/g' /var/lib/pgsql/11/data/pg_hba.conf

sudo systemctl start postgresql-11
sudo systemctl enable postgresql-11

psql -U postgres -c "CREATE USER sonar WITH ENCRYPTED password '$MY_PWD';"
psql -U postgres -c "CREATE DATABASE sonar OWNER sonar;"
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-6.4.zip
sudo yum -y install unzip
sudo unzip sonarqube-6.4.zip -d /opt
sudo mv /opt/sonarqube-6.4 /opt/sonarqube

sudo sed -i -e 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/g' /opt/sonarqube/conf/sonar.properties
sudo sed -i -e 's/#sonar.jdbc.password=/sonar.jdbc.password=huawei123/g' /opt/sonarqube/conf/sonar.properties
sudo sed -i -e 's/#sonar.jdbc.url=jdbc:postgresql/sonar.jdbc.url=jdbc:postgresql/g' /opt/sonarqube/conf/sonar.properties

echo "[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=root
Group=root
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/sonar.service
sudo systemctl start sonar
sudo systemctl enable sonar
sudo systemctl status sonar
