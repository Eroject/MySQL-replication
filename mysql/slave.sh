#!/bin/bash
ipmaster=192.168.43.195 
valeur_File=mysql-bin.000011
valeur_Position=1663
channel=channel3
mysql -u root -ptest <<EOF
STOP SLAVE;
CHANGE MASTER TO
  MASTER_HOST='$ipmaster',
  MASTER_USER='slave1',
  MASTER_PASSWORD='test',
  MASTER_LOG_FILE='$valeur_File',
  MASTER_AUTO_POSITION=0,
  MASTER_LOG_POS=$valeur_Position FOR CHANNEL '$channel';
START SLAVE;
EOF

