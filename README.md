# centos-scripts
CentOS utlity and build scripts, targeted at EL 6+

| Release     | Branch    | CentOS Version   |
| ----------- | --------- | ---------------- |
|             | master    | CentOS 6.x / 7.x |

## Scripts

### mail
Default values favour sendgrid smtp server, this can be overriden by ENV vars and/or commandline args.

 - mail/mailtest.sh
 - mail/configure.mail.sh
 
### other
     
 - listcronbydate.sh
 - restart_ntpd_and_sync.sh

## Usage

    cd ~
    git clone https://github.com/bgdevlab/centos-scripts.git
    
_optionally add to home user's bin directory_    

### examples
#### show all cron entries
     
    ./centos-scripts/listcronbydate.sh
    
#### test credentials for sendgrid smtp     

    ./centos-scripts/mail/mailtest.sh test_auth username password email@recipient.com

#### configure sendmail for use with sendgrid smtp 
This relies on the default `sendgrid` preference

    ./centos-scripts/mail/configure.mail.sh install username password    

#### configure sendmail for use with alternate smtp server
This relies on the explicit smtp server argument

    ./centos-scripts/mail/configure.mail.sh install username password my-smtp-server.com.au        