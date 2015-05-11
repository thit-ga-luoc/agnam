#!/usr/bin/env bash
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
UNAME=$1
[ "$UNAME" ] || exit
mkdir -p ../$UNAME
rm -vrf ../$UNAME/*.sh ../$UNAME/lib/*.sh ../$UNAME/lib/
cp -rf * ../$UNAME
sed -i "s/testscript/$UNAME/g" ../$UNAME/Environment.sh
chmod +x ../$UNAME/*.sh
