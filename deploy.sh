#!/bin/bash

s1=$(netstat -aon | grep 21111 | wc -l)
s2=$(netstat -aon | grep 21112 | wc -l)

if [[ $s1 -eq 0 ]]
then
    MIX_ENV=prod PORT=21111 mix phoenix.server
elif [[ $s2 -eq 0 ]]
then
    MIX_ENV=prod PORT=21112 mix phoenix.server
else
    echo "Please stop at least one server, or make sure port 21111 or 21112 is free!"
fi
