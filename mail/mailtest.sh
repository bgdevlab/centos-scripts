#!/bin/bash
tstamp=`date +%T`

# Environment variables you can override
#   SMTP_SERVER
#   EMAIL_FROM

usage() {
        echo "$0 test email_recipient [subject_append_message]"
        echo "$0 test_auth smtp_user smtp_password email_recipient [subject_append_message]"
}
 
# error handling
function err_exit { echo -e 1>&2; exit 1; }

if [ "$#" -lt 2 ]; then
        usage;
        exit 1;
fi
serviceAction="$1"

hostname=`hostname`
mailport=25
mailserver=${SMTP_SERVER:=smtp.sendgrid.net}
from=${EMAIL_FROM:-no-reply@$(hostname)}

generate_message() {
echo "HELO $hostname"
echo "MAIL FROM: <$from>"
echo "RCPT TO: <$recipient>"
echo "DATA"
echo "From: <$from>"
echo "To: <$recipient>"
echo "Subject: <$message>"
echo "$message"
echo "."
echo "QUIT"
}

base64Encode() {
    echo `echo -n "$1" | openssl base64`
} 

telnetmail_auth() {
    message="$hostname-${subject_append}"
    showSettings
    {
    sleep 3;
    echo "AUTH LOGIN";
    sleep 1;
    echo "$smtpuser"
    sleep 1;
    echo "$smtppass"
    sleep 1;
    echo "HELO $hostname";
    sleep 1;
    echo "MAIL FROM:<$from>";
    sleep 1;
    echo "RCPT TO: <${recipient}>";
    sleep 1;
    echo 'DATA';
    sleep 1;
    echo "To:${recipient}";
    echo "Subject: ${message}"
    echo "{$message}"
    echo '.';
    } | telnet $mailserver $mailport
}

telnetmail() {
    showSettings        
    {
    sleep 3;
    echo "HELO $hostname";
    sleep 1;
    echo "MAIL FROM:<$from>";
    sleep 1;
    echo "RCPT TO: <$recipient>";
    sleep 1;
    echo 'DATA';
    sleep 1;
    echo "To:$recipient";
    echo "Subject: <$message>"
    echo "$message"
    echo '.';
    } | telnet $mailserver $mailport
}
 
 
netcatmail() {
    # NOTE: this mechanism doesn't quite work as it completes too quickly ... not giving the mail server change to converse.
    echo "---- Conversation prepared  ---"
    generate_message
    echo ""
    echo "---- Using NetCat to talk with Mail Server ---"
    generate_message | nc $mailserver $mailport || err_exit
}

showSettings() { 
    echo "Setting          hostname: $hostname"
    echo "Setting        mailserver: $mailserver"
    echo "Setting          mailport: $mailport"
    echo "Setting           message: $message"
    echo "Setting              from: $from"
    echo "Setting         recipient: $recipient"
} 


if [ "$serviceAction" == "test" ]; then

    if [ "$#" -eq 2 ]; then
        recipient=$2
        subject_append='mail-via-telnet'
        telnetmail
        
    elif [ "$#" -eq 3 ]; then
        recipient=$2;
        subject_append=$3
        telnetmail
        
    else
        usage
        exit -1;
    fi

elif [ "$serviceAction" == "test_auth" ]; then
    echo "Setting         smtp user: $2"
    echo "Setting         smtp pass: $3"
    if [ "$#" -lt 3 ]; then
        echo "Require smtp_user smtp_password recipient"
        usage;
        exit 1;
    elif [ "$#" -eq 4 ]; then
        smtpuser=$(base64Encode "$2")
        smtppass=$(base64Encode "$3")
        recipient=$4
        subject_append='mail-via-telnet'
        telnetmail_auth
        
    elif [ "$#" -eq 5 ]; then
        smtpuser=$(base64Encode "$2")
        smtppass=$(base64Encode "$3")
        recipient=$4
        subject_append=$5
        telnetmail_auth
        
    else
        usage
        exit -1;
    fi
else
    lognow "action is - show usage()"
    usage        
fi
 
exit 0