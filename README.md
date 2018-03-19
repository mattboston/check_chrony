# check_chrony
Nagios check to see if Chrony(NTP) service.  Forked from https://exchange.nagios.org/directory/Plugins/Network-Protocols/NTP-and-Time/check_ntp(chrony)/details

Original script would only work on Systemd systems.  New script will work on both.

check the chrony service if its running or not ,if running them it will check if the Leap status is in normal status or not.if not this means that you have to check the connectivity between your server and NTP server.if all the previous is working well,the script will compare between local machine time and NTP time and give the nagios status accordingly.

this plugin also support performance data for graphing the values
