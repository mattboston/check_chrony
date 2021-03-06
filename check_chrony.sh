#!/bin/bash
#Author: Abd Alhameed Ghaith (https://exchange.nagios.org/directory/Plugins/Network-Protocols/NTP-and-Time/check_ntp(chrony)/details)
#Date:06/04/2016
#Author: Matt Shields (https://github.com/mattboston/check_chrony) - Modified to use with both Systemd and sysvinit
#Date:2018-03-19
#Purpose: Check the chrony service if its running or not.  If running, then it will check if the Leap status is in normal status or not.
# If not this means that you have to check the connectivity between your server and NTP server. If all the previous is working well,
# the script will compare between local machine time and NTP time and give the nagios status accordingly.

if [[ -z $1 ]] || [[ -z $2 ]]
then
  echo 'UNKNOWN - Please provide warning/critical values (in Millisecond).'
  exit 3
fi

NUMBER_VALIDATION='^[0-9]+$'
if ! [[ $1 =~ $NUMBER_VALIDATION ]] || ! [[ $2 =~ $NUMBER_VALIDATION ]]
then
  echo 'UNKNOWN - Please provide only number in the warning and critical values'
  exit 3
fi

if [ -f /etc/init.d/chronyd ]
then
  CHECK_SERVICE=`/etc/init.d/chronyd status | grep chronyd | awk -F 'is ' '{print $2}' | awk -F '.' '{print $1}'`
else
  CHECK_SERVICE=`systemctl status  chronyd.service   | grep Active | awk -F '(' '{print $2 }' | awk -F ')' '{print $1}'`
fi

if [[ "${CHECK_SERVICE}" == "dead" || "${CHECK_SERVICE}" == "stopped" ]]
then
  echo 'CRITICAL - Service is not running'
  exit 2
else
  CHECK_SERVER_SYNC=`chronyc tracking | grep 'Leap status' | awk -F ':' '{print $2}' | sed -e 's/^ //'`
  if [[ $CHECK_SERVER_SYNC == 'Not synchronised' ]]
  then
    echo  'CRITICAL - Server is not synchronised with the ntp server'
    exit 2
    else
    CHECK_TIME_DIFF=`chronyc tracking | grep 'System time' | awk -F ':' '{print $2}' |awk '{print $1}'| sed -e 's/^ //'`
    CHECK_TIME_DIFF_INT=`chronyc tracking | grep 'System time' | awk -F ':' '{print $2}' |awk '{print $1}'| sed -e 's/^ //' | awk -F '.' '{print $1}'`
    DIFF_IN_SECOND=`echo "(($CHECK_TIME_DIFF * 1000))" | bc`
    FAST_SLOW_VALUE=`chronyc tracking | grep 'System time' | awk -F ':' '{print $2}' |awk '{print $3}'| sed -e 's/^ //'`
      if [[ $CHECK_TIME_DIFF_INT -gt $1  ]] && [[ $CHECK_TIME_DIFF_INT -lt $2  ]]
      then
        echo "WARNING - time is $CHECK_TIME_DIFF_INT $FAST_SLOW_VALUE of NTP Time"
        echo "|Time Differences in=$CHECK_TIME_DIFF"
        exit 1
      elif [[ $CHECK_TIME_DIFF_INT -ge $2 ]]
      then
        echo "CRITICAL time is $CHECK_TIME_DIFF $FAST_SLOW_VALUE of NTP Time"
        echo "|Time Differences in=$CHECK_TIME_DIFF"
        exit 2
      else
        echo "OK - time is $CHECK_TIME_DIFF $FAST_SLOW_VALUE of NTP Time"
        echo "|Time Differences in=$CHECK_TIME_DIFF"
        exit 0
      fi
  fi
fi
