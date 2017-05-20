#!/bin/bash

name=$1
pillar_path=$2
if [ ! $pillar_path ]; then
    pillar_path=/srv/pillar/files/vpn-keys/
fi

if [ -f $pillar_path$name.crt ] && [ -f $pillar_path$name.key ]; then
    echo "key and crt already exist for $name"
    exit 0
fi

cd /usr/share/easy-rsa
source vars
./pkitool $name

if [ ! -f keys/$name.crt ]; then
    echo "Failed to create client crt"
    exit 1
fi

cp keys/$name.* $pillar_path
