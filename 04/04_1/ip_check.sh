#!/bin/bash

echo start
for ip in 192.168.0.1 173.194.222.113 87.250.250.242; do
  for i in {1..5}; do
    nc -z $ip 80
    result=$?
    echo "$(date): $ip - $result" >> ip_check.log
  done;
done
echo "done"
