#!/bin/bash
id=1
DB_NAME= 
UTILISATEUR_MYSQL=slave1
# Fix des permissions du fichier de configuration
sudo chmod a+xwr /etc/mysql/mysql.conf.d/mysqld.cnf
sudo bash -c "cat <<EOL > /etc/mysql/my.cnf
# The MySQL database server configuration file.
#
# You can copy this to one of:
# - \"/etc/mysql/my.cnf\" to set global options,
# - \"~/.my.cnf\" to set user-specific options.
#
# One can use all long options that the program supports.
# Run program with --help to get a list of available options and with
# --print-defaults to see which it would actually understand and use.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html
#
#
# * IMPORTANT: Additional settings that can override those from this file!
#   The files must end with '.cnf', otherwise they'll be ignored.
#
[mysqld]
user            = mysql
bind-address           = 0.0.0.0
#mysqlx-bind-address    = 0.0.0.0
key_buffer_size         = 16M
myisam-recover-options  = BACKUP
log_error = /var/log/mysql/error.log
server-id               = $id
gtid_mode = ON
enforce_gtid_consistency = ON
log_bin                 = /var/log/mysql/mysql-bin.log
max_binlog_size   = 100M
binlog_do_db            = $DB_NAME
relay_log = /var/log/mysql/mysql-relay-bin.log
master_info_repository = TABLE
relay_log_info_repository = TABLE

!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/
EOL" 

sudo bash -c "cat <<EOL > /etc/mysql/mysql.conf.d/mysqld.cnf
[mysqld]
user            = mysql
bind-address           = 0.0.0.0
#mysqlx-bind-address    = 0.0.0.0
key_buffer_size         = 16M
myisam-recover-options  = BACKUP
log_error = /var/log/mysql/error.log
server-id               = $id
gtid_mode = ON
enforce_gtid_consistency = ON
log_bin                 = /var/log/mysql/mysql-bin.log
max_binlog_size   = 100M
binlog_do_db            = $DB_NAME
relay_log = /var/log/mysql/mysql-relay-bin.log
master_info_repository = TABLE
relay_log_info_repository = TABLE
EOL"

sudo service mysql restart
mysql -u root -ptest -e "stop slave; RESET SLAVE ALL;"
sudo service mysql restart
mysql -u root -ptest <<EOF
STOP SLAVE;
CREATE DATABASE IF NOT EXISTS $DB_NAME;
STOP SLAVE;
CREATE USER IF NOT EXISTS '$UTILISATEUR_MYSQL'@'%' IDENTIFIED BY 'test';
GRANT REPLICATION SLAVE ON *.* TO '$UTILISATEUR_MYSQL'@'%';
ALTER USER '$UTILISATEUR_MYSQL'@'%' IDENTIFIED WITH mysql_native_password BY 'test';
GRANT ALL PRIVILEGES ON *.* TO '$UTILISATEUR_MYSQL'@'%';
FLUSH PRIVILEGES;
EOF
