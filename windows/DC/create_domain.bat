@echo off

set SUBNET=1.127.10
set DOMAIN=vmware.local
set NTP=10.127.1.10
set SCRIPT_DIR=%USERPROFILE%\Desktop\DC

powershell.exe -executionpolicy remotesigned -file %SCRIPT_DIR%\add_role.ps1
dcpromo /unattend:%SCRIPT_DIR%\unattend.txt

net stop w32time
w32tm /config /syncfromflags:manual /manualpeerlist:"%NTP%"
w32tm /config /reliable:yes

schtasks /create /tn "Configure DNS" /xml %SCRIPT_DIR%\config_dns_task.xml

shutdown /r /c "finish dcpromo process"