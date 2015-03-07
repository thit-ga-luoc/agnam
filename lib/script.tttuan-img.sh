#!/bin/sh
####### Check double domain for 3T ######## IN : temp1  #### OUT : output2
        blogspot=$(cat $temp1 | grep -i 'slides_page_url_path' | grep http  | sed -re 's/(.*)\["//g' | sed 's/"\];//g' | sed 's/","/\n/g') #blogspot
        tttuan=$(cat $temp1 | grep -i 'slides_page_path' | grep http  | sed -re 's/(.*)\["//g' | sed 's/"\];//g' | sed 's/","/\n/g' )    #truyentranhtuan => sort
        if [ ! -z "$tttuan" ]; then
                if [ ! -z "$tttuan" ] &&  [ ! -z "$blogspot" ]; then
			## Domain : Blogspot
			echo $(echo $(cat $temp1 | grep -i 'slides_page_url_path' | grep http  | sed -re 's/(.*)\["//g' | sed 's/"\];//g') | rev | cut -c 2- | rev) | sed 's/","/\n/g' > $output2
                else
			## Domain : TruyenTranhTuan
			echo $(echo $(cat $temp1 | grep -i 'slides_page_path' | grep http  | sed -re 's/(.*)\["//g' | sed 's/"\];//g') | rev | cut -c 2- | rev) | sed 's/","/\n/g'  | sort -V > $output2

                fi
        else
        	## Domain : Blogspot
                echo $(echo $(cat $temp1 | grep -i 'slides_page_url_path' | grep http  | sed -re 's/(.*)\["//g' | sed 's/"\];//g') | rev | cut -c 2- | rev) | sed 's/","/\n/g' > $output2
        fi
	rm -rf $temp1
