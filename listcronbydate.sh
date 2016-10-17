# https://gist.github.com/stefanocudini/4704616
cron_user='*'
if [ $1 ]; then
	cron_user=$1;
fi
egrep -rv '^\s*[#;]|^\s*$' /var/spool/cron/${cron_user} | perl -ane 'print join("\t", @F[0..5], join(" ", @F[6..$#F])),"\n" unless /MAILTO/' | sort -nt$'\t' -k2 -k1 | column -t -s$'\t'
