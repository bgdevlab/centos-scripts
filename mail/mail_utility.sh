#!/bin/bash

# default property values
#EMAIL_FROM=${EMAIL_FROM:-$1}
EMAIL_FROM=${EMAIL_FROM:=no-reply@$(hostname)}

#EMAIL_FROM_ALIAS=${EMAIL_FROM_ALIAS:-$2}
EMAIL_FROM_ALIAS=${EMAIL_FROM_ALIAS:-$EMAIL_FROM}

function _lognow() {
	local ident="$1"
	local tstamp=`date +%F\ %H:%M:%S`
	local message="$2"

	echo "$tstamp,$ident,$message"
}

function lognow() {
	_lognow "utility" "$1"
}

function getMuttEmailFrom() {
	if [ "$#" -ne 2 ]; then 
		lognow "missing arguments in call to getMuttEmailFrom(from_email, from_email_alias)";
		exit -1;
	fi
	from_email="$1"
	from_alias="$2"
	echo "unmy_hdr from; my_hdr From: $from_email;set realname=\"$from_alias\""
}

function sendEmail() {
	   
	if [ "$#" -ne 3 ]; then 
		lognow "missing arguments in call to sendMail(subject,body,recipients)";
		exit -1;
	fi

	sendEmail_from_option=$(getMuttEmailFrom "$EMAIL_FROM" "$EMAIL_FROM_ALIAS")

	local subject=$1
	local messagebody=$2
	local recipients=$3
		
	lognow "sendmail - $subject to $recipients without attachment"
	echo -e "$messagebody" | mutt -e "$sendEmail_from_option" -s "$subject" -c $recipients

	return 0
}

function sendEmailWithAttachment() {

	if [ "$#" -ne 4 ]; then 
		lognow "missing arguments in call to sendMailWithAttachment(subject,body,recipients,attachment_filepath)";
		exit -1;
	fi
	
	sendEmail_from_option=$(getMuttEmailFrom "$EMAIL_FROM" "$EMAIL_FROM_ALIAS")

	local subject=$1
	local messagebody=$2
	local recipients=$3
	local attachment=$4
		
	lognow "sendemail - $subject to $recipients with attachment '$attachment'"
	echo -e "$messagebody" | mutt -e "$sendEmail_from_option" -s "$subject" -a "$attachment" -c $recipients

	return 0
}




