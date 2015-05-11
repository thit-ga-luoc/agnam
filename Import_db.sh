#!/bin/sh
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'

# Use : import_chapter_to_db import chapter normal old

import_chapter_to_db(){
local path="/Data/www/images"

## import chapter normal new
local method=$1 #import
local type=$2 #story-chapter
local story_type=$3 #truyenbua-normal
local import_type=$4 #new-old
local path_file_import=${5:-$ImportDBList}
local list_import=$(cat $path_file_import | awk '{print $1,$2}' | tr ' ' ',' | tr '\n' ' ')
[ "$type" == "chapter" ] && echo -n > $ImportDBList
for i in $list_import
do
  project=$(echo $i | cut -d',' -f1)
  chapter=$(echo $i | cut -d',' -f2)
  echo "$method $type $story_type $project $chapter" >> /tmp/check_script
    if [ "$method" == "import" ]; then
        if [ "$type" == "story" ]; then
            if [ "$story_type" == "truyenbua" ]; then
                if [ "$import_type" == "new" ]; then
                    for i in $project
                    do
                        docker exec 5541e2a2933c /Data/www/django/backend_code/LiveComicService/live-comic-env/bin/python2.7 /Data/www/django/backend_code/LiveComicService/manage.py insert_story --project_dir="$path"/"$i" --is_nonsense=1
                        echo "import story "$i" success" >> /root/tanluong/content_log
                    done
                elif [ "$import_type" == "old" ]; then
                    for i in $project
                    do
                        docker exec 5541e2a2933c /Data/www/django/backend_code/LiveComicService/live-comic-env/bin/python2.7 /Data/www/django/backend_code/LiveComicService/manage.py remove_story --type=story --project_name="$i"
                        docker exec 5541e2a2933c /Data/www/django/backend_code/LiveComicService/live-comic-env/bin/python2.7 /Data/www/django/backend_code/LiveComicService/manage.py insert_story --project_dir="$path"/"$i" --is_nonsense=1
                        echo "import story "$i" success" >> /root/tanluong/content_log
                    done
                else
                    echo "Use new|old only"
                fi
            elif [ "$story_type" == "normal" ]; then
                if [ "$import_type" == "new" ]; then
                    for i in $project
                    do
                        docker exec 5541e2a2933c /Data/www/django/backend_code/LiveComicService/live-comic-env/bin/python2.7 /Data/www/django/backend_code/LiveComicService/manage.py insert_story --project_dir="$path"/"$i"
                        echo "import story "$i" success" >> /root/tanluong/content_log
                    done
                elif [ "$import_type" == "old" ]; then
                    for i in $project
                    do
                        docker exec 5541e2a2933c /Data/www/django/backend_code/LiveComicService/live-comic-env/bin/python2.7 /Data/www/django/backend_code/LiveComicService/manage.py remove_story --type=story --project_name="$i"
                        docker exec 5541e2a2933c /Data/www/django/backend_code/LiveComicService/live-comic-env/bin/python2.7 /Data/www/django/backend_code/LiveComicService/manage.py insert_story --project_dir="$path"/"$i"
                        echo "import story "$i" success" >> /root/tanluong/content_log
                    done
                else
                    echo "Use new|old only"
                fi
            else
                echo "Use truyenbua|normal only"
            fi
        elif [ "$type" == "chapter" ]; then
            if [ "$import_type" == "new" ]; then
                for i in $chapter
                do
                    docker exec 5541e2a2933c /Data/www/django/backend_code/LiveComicService/live-comic-env/bin/python2.7 /Data/www/django/backend_code/LiveComicService/manage.py insert_chapter --project_name="$project" --chapter_dir="$path"/"$project"/chapter-"$i"
                    echo "import chapter "$i" of "$project" success" >> /root/tanluong/content_log
                done
            elif [ "$import_type" == "old" ]; then
                for i in $chapter
                do
                    docker exec 5541e2a2933c /Data/www/django/backend_code/LiveComicService/live-comic-env/bin/python2.7 /Data/www/django/backend_code/LiveComicService/manage.py remove_story --type=chapter --project_name="$project" --chapter_name=chapter-"$i"
                    docker exec 5541e2a2933c /Data/www/django/backend_code/LiveComicService/live-comic-env/bin/python2.7 /Data/www/django/backend_code/LiveComicService/manage.py insert_chapter --project_name="$project" --chapter_dir="$path"/"$project"/chapter-"$i"
                    echo "import chapter "$i" of "$project" success" >> /root/tanluong/content_log
                done
            else
                echo "Use new|old only"
            fi
        else
            echo "User Story|Chapter only"
        fi
    else
        echo "Only use (import)"
    fi
done

}
