#! /bin/bash
/usr/bin/echo "Installing Zabbix , Wait please..."
rpm -ivh http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm

dnf install -y zabbix-server-pgsql zabbix-web-pgsql postgresql postgresql-server
su postgres -c "initdb -D /var/lib/pgsql/data"
su postgres -c "/usr/libexec/postgresql-ctl start -D /var/lib/pgsql/data -s -w -t 270"

psql -U postgres -c "CREATE DATABASE zabbix"
psql -U postgres -c "CREATE USER zabbix WITH PASSWORD 'zabbix'"
psql -U postgres -c "GRANT ALL ON DATABASE zabbix TO zabbix"
cat /usr/share/zabbix-postgresql/schema.sql | psql -U zabbix zabbix
cat /usr/share/zabbix-postgresql/images.sql | psql -U zabbix zabbix
cat /usr/share/zabbix-postgresql/data.sql | psql -U zabbix zabbix

/usr/sbin/nslcd && sleep 5
/usr/bin/echo "Creating DB edt.org..."
/usr/bin/echo "admin" | kinit admin/admin
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
rm -rf /etc/openldap/slapd.d/*
slaptest -f /opt/docker/slapd-edt.org.acl.conf -F /etc/openldap/slapd.d
chown -R ldap.ldap /etc/openldap/slapd.d/
chown -R ldap.ldap /var/lib/ldap/
/usr/sbin/slapd
/usr/bin/echo "Contacting to master LDAP, Wait please..." && sleep 15
kdestroy
/usr/bin/echo "Thanks for Waiting , Done"
/bin/bash
