#!/usr/bin/env bash
PageList=$2
hxnormalize -x $1 | grep "data = " | sed -re "s/http:\/\//\nhttp:\/\//g;s/\||\;//g" -e "s/'//g" |
 grep -i -e "http:\|.png\|.jpg" > $PageList
