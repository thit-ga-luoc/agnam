#!/bin/sh
####### Check double domain for 3T ######## IN : temp1  #### OUT : output2
PageList=$2
        BLOGSPOT=$(cat $1 | grep -i 'slides_page_url_path' | grep http  | sed -re 's/(.*)\["//g' | sed 's/"\];//g' | sed 's/","/\n/g') #blogspot
        TTTUAN=$(cat $1 | grep -i 'slides_page_path' | grep http  | sed -re 's/(.*)\["//g' | sed 's/"\];//g' | sed 's/","/\n/g' )    #truyentranhtuan => sort
        if [ ! -z "$TTTUAN" ]; then
                if [ ! -z "$TTTUAN" ] &&  [ ! -z "$BLOGSPOT" ]; then
			## Domain : Blogspot
			echo $(echo $(cat $1 | grep -i 'slides_page_url_path' | grep http  | sed -re 's/(.*)\["//g' | sed 's/"\];//g') | rev | cut -c 2- | rev) | sed 's/","/\n/g' > $PageList
                else
			## Domain : TruyenTranhTuan
			echo $(echo $(cat $1 | grep -i 'slides_page_path' | grep http  | sed -re 's/(.*)\["//g' | sed 's/"\];//g') | rev | cut -c 2- | rev) | sed 's/","/\n/g'  | sort -V > $PageList
                fi
        else
        	## Domain : Blogspot
                echo $(echo $(cat $1 | grep -i 'slides_page_url_path' | grep http  | sed -re 's/(.*)\["//g' | sed 's/"\];//g') | rev | cut -c 2- | rev) | sed 's/","/\n/g' > $PageList
        fi

