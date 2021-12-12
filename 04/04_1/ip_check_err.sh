#!/bin/bash


while (( 1==1 )); do
  for ip in 192.168.0.1 173.194.222.113 87.250.250.242; do
    for i in {1..5}; do
      nc -z $ip 80
      result=$?
      echo "$(date): $ip - $result" >> ip_check_err.log
      if (($result != 0)) ; then
        echo $ip >> error
        exit 0
      fi
    done;
  done
done