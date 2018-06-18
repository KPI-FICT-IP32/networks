#!/bin/sh

dnf install -y postfix

cat >/etc/postfix/main.cf <<'EOF'
myhostname = mail.zone05.net
mydestination =
	$myhostname,
	$mydomain,
	localhost,
	localhost.$mydomain
myorigin = $myhostname

alias_database = hash:/etc/aliases
alias_maps = hash:/etc/aliases

append_dot_mydomain = no
biff = no

command_directory = /usr/sbin
config_directory = /etc/postfix
daemon_directory = /usr/libexec/postfix
data_directory = /var/lib/postfix
debug_peer_level = 2

disable_vrfy_command = yes

html_directory = no
inet_interfaces = all
inet_protocols = all
local_recipient_maps = $alias_maps
mail_owner = postfix
mailbox_size_limit = 409600000
mailq_path = /usr/bin/mailq.postfix
manpage_directory = /usr/share/man
message_size_limit = 8192000
mynetworks = 127.0.0.1/32 [::1]/128
mynetworks_style = host

newaliases_path = /usr/bin/newaliases.postfix
queue_directory = /var/spool/postfix
readme_directory = /usr/share/doc/postfix-2.6.6/README_FILES
sample_directory = /usr/share/doc/postfix-2.6.6/samples
sendmail_path = /usr/sbin/sendmail.postfix
setgid_group = postdrop

smtp_tls_security_level = may
smtpd_banner = $myhostname ESMTP
smtpd_hello_required = yes
smtpd_recipient_restrictions = 
	reject_unknown_recipient_domain,
	permit_mynetwoeks,
    reject_non_fqdn_recipient,
	reject_unauth_destination,
	reject_unverified_recipient,
	permit
smtpd_sasl_path = private/auth
smtpd_sasl_type = dovecot
smtpd_tls_cert_file = /etc/pki/dovecot/certs/dovecot.pem
smtpd_tls_key_file = /etc/pki/dovecot/private/dovecot.pem
smtpd_tls_security_level = may
smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_scache
strict_rfc821_envelopes = yes
unknown_local_recipient_reject_code = 550
virtual_alias_domains = zone05.net
virtual_alias_maps = hash:/etc/postfix/virtual
virtual_mailbox_domains = zone05.net
virtual_transport = lmtp:unix:private/dovecot-lmtp
EOF

if grep -q 'srv01' /etc/aliases; then
	echo "aliases already configured"
else
	echo "srv01: alpha" >> /etc/aliases
	echo "srv02: beta" >> /etc/aliases
	echo "srv03: gamma" >> /etc/aliases
	echo "srv04: delta" >> /etc/aliases
	echo "srv05: omega" >> /etc/aliases
	newaliases
fi

if grep -q "^submission" /etc/postfix/master.cf; then
	echo "master.cf already configured"
else
cat >>/etc/postfix/master.cf <<'EOF'
submission inet n       -       n       -       -       smtpd
  -o smtpd_tls_security_level=encrypt
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_recipient_restrictions=reject_non_fqdn_recipient,reject_unknown_recipient_domain,permit_sasl_authenticated,reject
EOF
fi
