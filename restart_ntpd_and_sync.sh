#!/usr/bin/env bash
TIME_SERVER=${TIME_SERVER:-0.pool.ntp.org}
if [ $1 ]; then
    TIME_SERVER="$1"
fi

grep 'release 7.' /etc/redhat-release > /dev/null

if [ $? -eq 0 ]; then
	/bin/systemctl stop ntpd.service || true
	/usr/sbin/ntpdate $TIME_SERVER || true
	/bin/systemctl start ntpd.service || true
else
	/sbin/service ntpd stop || true
	/usr/sbin/ntpdate $TIME_SERVER || true
	/sbin/service ntpd start || true
fi
