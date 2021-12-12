#!/bin/bash

while ((1==1)) ; do
  curl  -k -0 "https://$1:443"
  if (($? != 0)) ; then
    date >> curl.log
  else
    break
  fi
done