#!/usr/bin/env bash
TIME_SERVER=${TIME_SERVER:-0.pool.ntp.org}
if [ $1 ]; then
    TIME_SERVER="$1"
fi

grep 'release 7.' /etc/redhat-release > /dev/null

if [ $? -eq 0 ]; then
	/bin/systemctl stop  ntpd.service
	/usr/sbin/ntpdate $TIME_SERVER
	/bin/systemctl start  ntpd.service
else
	/sbin/service ntpd stop
	/usr/sbin/ntpdate $TIME_SERVER
	/sbin/service ntpd start
fi
