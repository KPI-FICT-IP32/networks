# Prerequisites

docker and docker-compose installed

# Images

 - `dns_master` and `dns_slave` - taken from previous lab, with some additional configuration (MX and PTR records in DNS table primarily)
 - `mail_server` - mail server implementation
   - `sendmail.mc` - configuration, similar to default sendmail's, but with removed `DAEMON_OPTIONS(`Port=smtp,Addr=127.0.0.1, Name=MTA’)dnl` configuration to expose server to the external networks
 - `test_host` - test host for sendmail clients, used for sending email to our mailserver
