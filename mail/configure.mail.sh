#!/bin/sh

# Environment variables you can override
#   MAIL_ACTION
#   MAIL_SMART_HOST
#   MAIL_UNAME
#   MAIL_UPASS

ident=`basename "$0"`
logfile="`pwd`/log.$ident"
errlogfile=$logfile
touch $logfile


# defaults
serviceAction=install
serviceSmartHost=smtp.sendgrid.net

lognow(){
    #ident="configure.mail"
    local tstamp=`date +%F\ %H:%M:%S`
    local message="$1"
    echo "$tstamp,$ident,$message" | tee -a $logfile
}

configureMail() {

	if [ "$#" -ne 3 ]; then 
		lognow "missing arguments in call to configureMail(smtp_server, smtp_user, smtp_password)";
		exit -1;
	fi
	smtp_server="$1"
	smtp_user="$2"
	smtp_password="$3"
    # http://dev.mutt.org/trac/wiki/MuttFaq/Header

    lognow "modfy SMART_HOST for sendmail"
    

  cat << EOF >> "/etc/mail/access"
AuthInfo:$smtp_server "U:$smtp_user" "P:$smtp_password" "M:PLAIN"
EOF
    
    # mutlitple SMARTHOSTS are OK... sendmail only used the last one.
    cp /etc/mail/sendmail.mc .
    cat >> ./sendmail.mc << EOM
define(\`SMART_HOST', \`$smtp_server')dnl
dnl FEATURE(\`access_db')dnl
define(\`RELAY_MAILER_ARGS', \`TCP $h 587')dnl
define(\`ESMTP_MAILER_ARGS', \`TCP $h 587')dnl

EOM

    su -c "cp -f ./sendmail.mc /etc/mail/sendmail.mc"
    m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
    makemap hash access < /etc/mail/access && mv -f access.db /etc/mail/access.db

    lognow "stopping postfix (if its running)"
    /sbin/service postfix stop
    /sbin/chkconfig --add postfix
    /sbin/chkconfig postfix off

    lognow "restart sendmail"
    /sbin/service sendmail restart
}





usage() {
    cat << USAGE 
This script configures the sendmail environment.
The script relies on 3 environment variables, MAIL_SMART_HOST MAIL_UNAME and MAIL_UPASS, they both MUST be used OR none at all relying on the default.
  MAIL_SMART_HOST - [ "smarthost" ]
  MAIL_UNAME - [ "sendmail username" ]
  MAIL_UPASS  - [ "sendmail password" ]
  
Command line argument override these environment variables, the order in   
    MAIL_SMART_HOST   MAIL_UNAME    MAIL_UPASS

    $0 install smpt_username smtp_password
or
    $0 install smpt_username smtp_password smtp_servername

USAGE
}

cleanup() {
    lognow "cleaning: nothing to do"
}


# Environment variables are required for Packer builds.
if [ -n "$MAIL_ACTION" ]; then
    serviceAction=$MAIL_ACTION
fi

if [ -n "$MAIL_SMART_HOST" ]; then
    serviceSmartHost=$MAIL_SMART_HOST
    lognow "env:setting mail host to $serviceSmartHost"
fi

if [ -n "$MAIL_UNAME" ]; then
    serviceName=$MAIL_UNAME
    lognow "env: setting serviceName to $serviceName"
fi

if [ -n "$MAIL_UPASS" ]; then
    servicePassword=$MAIL_UPASS
    lognow "env:setting mail pass to $servicePassword"
fi

# Command line arguments override Environment variables.

if [ "$#" -gt 0 ]; then
    # special case for help
    serviceAction="$1"
fi


if [ "$serviceAction" == "info" ]; then

    lognow "cat /etc/mail/sendmail.mc | grep SMART"
    exit 0

elif [ "$serviceAction" == "install" ]; then

    if [ "$#" -gt 2 ]; then
        # special case for help
        serviceName="$2"
        servicePassword="$3"
    fi
    if [ "$#" -gt 3 ]; then
        serviceSmartHost="$4"
    fi

    if [ "${serviceAction}" ] && [ "${serviceName}" ] && [ "${servicePassword}" ] ; then
        echo "ACTION=${serviceAction}"
        echo "NAME=${serviceName}"
        echo "PASS=${servicePassword}"
        echo "SMARTHOST=${serviceSmartHost}"
    else
        usage
    fi

    lognow "configure sendmail with $serviceName $servicePassword and smarthost $serviceSmartHost"
    configureMail "$serviceSmartHost" "$serviceName" "$servicePassword"

elif [ "$serviceAction" == "clean" ]; then

    cleanup

elif [ "$serviceAction" == "help" ] || [ "$serviceAction" == "usage" ] || [ "$serviceAction" == "--help" ] ; then

    lognow "action is - show usage()"
    usage

else
    lognow "action is - show usage()"
    usage        
fi
