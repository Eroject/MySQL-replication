#!/bin/bash


MYSQL_USER="root"
MYSQL_PASSWORD="test"
SHOW_MASTER_STATUS=$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW MASTER STATUS" --skip-column-names)
BINLOG_FILE_NAME=$(echo "$SHOW_MASTER_STATUS" | awk '{print $1}')
BINLOG_POSITION=$(echo "$SHOW_MASTER_STATUS" | awk '{print $2}')
echo "$BINLOG_FILE_NAME"
echo "$BINLOG_POSITION"

