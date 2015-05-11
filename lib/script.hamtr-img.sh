#!/usr/bin/env bash
PageList=$2
hxnormalize -x $1 | hxselect "#content_chap" | tr '\n' ' ' | sed 's/src="http/\nhttp/g' |
sed -re 's/"(.*)//'g | grep -v -e "bestmedia" -e "div class"  | sed '/^$/d' > $PageList
