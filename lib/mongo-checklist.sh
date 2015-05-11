#!/usr/bin/env bash

#Valid/Invalid Story
STORY_INVALID=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=invalid-story&job=stoken")  ## => The value is Unavailable
STORY_VALID=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=dragon-ball&job=stoken")  ## => StoryIsEnded  ###
STORY_LIST=$(curl -s "http://127.0.0.1:4446/mongo/get_data?job=story")  ## => midori-no-hibi miyuki monster-soul mx0 naruto

#Valid/Invalid chapter
CHAPTER_INVALID=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=naruto&chapter_name=chapter-2000&job=md5") ## => The value is Unavailable
CHAPTER_VALID=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=naruto&chapter_name=chapter-2&job=md5") ## => ThisIsMD5TestCase
CHAPTER_LIST=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=naruto&job=chapter") ## => "chapter-1 chapter-10 chapter-100 chapter-101 chapter-102 chapter-103"

#stoken
# curl -s "http://127.0.0.1:4446/mongo/import_data?story_name=dragon-ball&stoken=StoryIsEnded&job=stoken"
STOKEN_INVALID=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=naruto&job=stoken")  ## => The value is Empty
# STOKEN_VALID=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=dragon-ball&job=stoken") ## => StoryIsEnded  Same with STORY_VALID

#MD5
# curl -s "http://127.0.0.1:4446/mongo/import_data?story_name=naruto&chapter_name=chapter-2&cprofile=md5&job=md5"
MD5_INVALID=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=naruto&chapter_name=chapter-1&job=md5") ## => The value is Empty
MD5_VALID=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=naruto&chapter_name=chapter-2&job=md5") ## => ThisIsMD5TestCase

#cprofile
# curl -s "http://127.0.0.1:4446/mongo/import_data?story_name=naruto&chapter_name=chapter-2&cprofile=ThisIsCprofileTestCase&job=cprofile"
CPROFILE_INVALID=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=naruto&chapter_name=chapter-1&job=cprofile") ## => The value is Empty
CPROFILE_VALID=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=naruto&chapter_name=chapter-2&job=cprofile") ## => ThisIsCprofileTestCase

#Page quality
# curl -s "http://127.0.0.1:4446/mongo/import_data?story_name=naruto&chapter_name=chapter-2&cprofile=ThisIsCprofileTestCase&job=cprofile"
PAGE_QUALITY_1=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=naruto&chapter_name=chapter-1&job=page") ## => 56
PAGE_QUALITY_2=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=naruto&chapter_name=chapter-2&job=page")  ## => 23

#ctoken
CTOKEN_tttuan=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=naruto&chapter_name=chapter-252&job=ctoken") ## => tttuan
CTOKEN_blogtr=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=naruto&chapter_name=chapter-253&job=ctoken") ## => blogtr
CTOKEN_hamtr=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=truyen-tranh-hai&chapter_name=chapter-91&job=ctoken") ## => hamtr
CTOKEN_vechai=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=toriko&chapter_name=chapter-16&job=ctoken") ## => vechai
CTOKEN_Empty=$(curl -s "http://127.0.0.1:4446/mongo/get_data?story_name=ao-no-exorcist&chapter_name=chapter-2&job=ctoken") ## => The value is Empty


#Valid/Invalid Story
if [ "$STORY_INVALID" == "The value is Unavailable" ]; then
    echo "STORY_INVALID : PASSED - Received : $STORY_INVALID"
else
    echo "STORY_INVALID : FAILED - Expected: \"The value is Unavailable\" but Received: \"$STORY_INVALID\" "
fi

if [ "$STORY_VALID" == "StoryIsEnded" ]; then
    echo "STORY_VALID : PASSED - Received : $STORY_VALID"
else
    echo "STORY_VALID : FAILED -  Expected: \"StoryIsEnded\" but Received: \"$STORY_VALID\" "
fi

if [ "$(echo $STORY_LIST | grep -o "midori-no-hibi miyuki monster-soul mx0 naruto")" == "midori-no-hibi miyuki monster-soul mx0 naruto" ]; then
    echo "STORY_LIST : PASSED"
else
    echo "STORY_LIST : FAILED -  Expected: \"midori-no-hibi miyuki monster-soul mx0 naruto\" "
fi

#Valid/Invalid chapter
if [ "$CHAPTER_INVALID" == "The value is Unavailable" ]; then
    echo "CHAPTER_INVALID : PASSED - Received : $CHAPTER_INVALID"
else
    echo "CHAPTER_INVALID : FAILED - Expected: \"The value is Unavailable\" but Received: \"$CHAPTER_INVALID\" "
fi

if [ "$CHAPTER_VALID" == "ThisIsMD5TestCase" ]; then
    echo "CHAPTER_VALID : PASSED - Received : $CHAPTER_VALID"
else
    echo "CHAPTER_VALID : FAILED - Expected: \"ThisIsMD5TestCase\" but Received: \"$CHAPTER_VALID\" "
fi

if [ "$(echo $CHAPTER_LIST | grep -o "chapter-1 chapter-10 chapter-100 chapter-101 chapter-102 chapter-103")" == "chapter-1 chapter-10 chapter-100 chapter-101 chapter-102 chapter-103" ]; then
    echo "CHAPTER_LIST : PASSED "
else
    echo "CHAPTER_LIST : FAILED - Expected: \"chapter-1 chapter-10 chapter-100 chapter-101 chapter-102 chapter-103\" "
fi

#stoken
if [ "$STOKEN_INVALID" == "The value is Empty" ]; then
    echo "STOKEN_INVALID : PASSED - Received : $STOKEN_INVALID"
else
    echo "STOKEN_INVALID : FAILED - Expected: \"The value is Empty\" but Received: \"$STOKEN_INVALID\" "
fi

if [ "$STORY_VALID" == "StoryIsEnded" ]; then
    echo "STOKEN_VALID : PASSED  - Received : $STORY_VALID"
else
    echo "STOKEN_VALID : FAILED -  Expected: \"StoryIsEnded\" but Received: \"$STORY_VALID\" "
fi

#MD5
if [ "$MD5_INVALID" == "The value is Empty" ]; then
    echo "MD5_INVALID : PASSED - Received : $MD5_INVALID"
else
    echo "MD5_INVALID : FAILED - Expected: \"The value is Empty\" but Received: \"$MD5_INVALID\" "
fi

if [ "$MD5_VALID" == "ThisIsMD5TestCase" ]; then
    echo "MD5_VALID : PASSED  - Received : $MD5_VALID"
else
    echo "MD5_VALID : FAILED - Expected: \"ThisIsMD5TestCase\" but Received: \"$MD5_VALID\" "
fi

#cprofile
if [ "$CPROFILE_INVALID" == "The value is Empty" ]; then
    echo "CPROFILE_INVALID : PASSED - Received : $CPROFILE_INVALID"
else
    echo "CPROFILE_INVALID : FAILED - Expected: \"The value is Empty\" but Received: \"$CPROFILE_INVALID\" "
fi

if [ "$CPROFILE_VALID" == "ThisIsCprofileTestCase" ]; then
    echo "CPROFILE_VALID : PASSED - Received : $CPROFILE_VALID"
else
    echo "CPROFILE_VALID : FAILED - Expected: \"ThisIsCprofileTestCase\" but Received: \"$CPROFILE_VALID\" "
fi

#Page quality

if [ "$PAGE_QUALITY_1" == "56" ]; then
    echo "PAGE_QUALITY_1 : PASSED - Received : $PAGE_QUALITY_1"
else
    echo "PAGE_QUALITY_1 : FAILED - Expected: \"56\" but Received: \"$PAGE_QUALITY_1\" "
fi

if [ "$PAGE_QUALITY_2" == "23" ]; then
    echo "PAGE_QUALITY_2 : PASSED - Received : $PAGE_QUALITY_2"
else
    echo "PAGE_QUALITY_2 : FAILED - Expected: \"23\" but Received: \"$PAGE_QUALITY_2\" "
fi

#ctoken
if [ "$CTOKEN_tttuan" == "tttuan" ]; then
    echo "CTOKEN_tttuan : PASSED - Received : $CTOKEN_tttuan"
else
    echo "CTOKEN_tttuan : FAILED - Expected: \"tttuan\" but Received: \"$CTOKEN_tttuan\" "
fi

if [ "$CTOKEN_blogtr" == "blogtr" ]; then
    echo "CTOKEN_blogtr : PASSED  - Received : $CTOKEN_blogtr"
else
    echo "CTOKEN_blogtr : FAILED - Expected: \"blogtr\" but Received: \"$CTOKEN_blogtr\" "
fi

if [ "$CTOKEN_hamtr" == "hamtr" ]; then
    echo "CTOKEN_hamtr : PASSED - Received : $CTOKEN_hamtr"
else
    echo "CTOKEN_hamtr : FAILED - Expected: \"hamtr\" but Received: \"$CTOKEN_hamtr\" "
fi

if [ "$CTOKEN_vechai" == "vechai" ]; then
    echo "CTOKEN_vechai : PASSED  - Received : $CTOKEN_vechai"
else
    echo "CTOKEN_vechai : FAILED - Expected: \"vechai\" but Received: \"$CTOKEN_vechai\" "
fi

if [ "$CTOKEN_Empty" == "The value is Empty" ]; then
    echo "CTOKEN_Empty : PASSED - Received : $CTOKEN_Empty"
else
    echo "CTOKEN_Empty : FAILED - Expected: \"The value is Empty\" but Received: \"$CTOKEN_Empty\" "
fi

