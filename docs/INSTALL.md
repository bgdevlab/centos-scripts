# install


    echo '*/5 * * * * /root/bin/restart_ntpd_and_sync.sh time.blueglue.com.au 2>&1 >> /var/log/ntpd_force_restart' >> /var/spool/cron/root`