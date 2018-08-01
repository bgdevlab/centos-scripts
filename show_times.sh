cron_user='*'
if [ $1 ]; then
	servers="$@";
fi
DNS_SERVER=10.20.1.25

for server in "$servers"
do
   hostname=$(nslookup $server $DNS_SERVER)
   echo -e "\n====================\n$server - $hostname\n"
   echo "PHP"
   ssh -i /home/dump/.ssh/id_dsa dump@$server "php -r 'echo \"\ninline php get timezone=\".date_default_timezone_get().\"\n\";'"
   ssh -i /home/dump/.ssh/id_dsa dump@$server "echo 'inspect php.ini';cat $(php -i | grep php.ini | cut -d '>' -f 2- | tr -d ' ') | grep timezone"
   ssh -i /home/dump/.ssh/id_dsa dump@$server "php -r \"echo date('m/d/Y h:i:s a', time());\";echo"

   echo "OS"
   ssh -i /home/dump/.ssh/id_dsa dump@$server "date +'%F %H:%M:%S %z %Z Inspected Server';TZ=':Australia/Sydney' date +'%F %H:%M:%S %z %Z NSW Reference';TZ=':UTC' date +'%F %H:%M:%S %z %Z GMT Reference'"
   ssh -i /home/dump/.ssh/id_dsa dump@$server 'cat /etc/sysconfig/clock;ls -l /etc/localtime'

   echo "DATABASE"
   ssh -i /home/dump/.ssh/id_dsa dump@$server "for pgconf in $(find /var/lib/pgsql/ -type f -name 'postgresql.conf'); do echo "inspect $pgconf";grep timezone $pgconf; done"
   ssh -i /home/dump/.ssh/id_dsa dump@$server "psql -U postgres -c 'select now()' | egrep '20[0-9]{2,}'"

done