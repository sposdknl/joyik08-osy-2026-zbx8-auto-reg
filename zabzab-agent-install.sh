#!/usr/bin/env bash

wget https://repo.zabbix.com/zabbix/8.0/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_8.0+debian13_all.deb
dpkg -i zabbix-release_latest_8.0+debian13_all.deb
apt-get update
apt-get install zabbix-agent2 -y
apt-get install zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql -y
systemctl enable zabbix-agent2.service
systemctl restart zabbix-agent2.service