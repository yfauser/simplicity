@echo off

set SUBNET="1.127.10"
set DOMAIN="vmware.local"

dnscmd /zoneadd %SUBNET%.in-addr.arpa /dsprimary
dnscmd /config %DOMAIN% /allowupdate 1
dnscmd /config %SUBNET%.in-addr.arpa /allowupdate 1

exit %ERRORLEVEL%