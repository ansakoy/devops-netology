#!/bin/bash

curl -k -0 "https://$1:443"
result=$?
while [ $result -ne 0 ] ; do
  date >> curl.log
  sleep 5
  curl -k -0 "https://$1:443"
  result=$?
done

echo "works"
