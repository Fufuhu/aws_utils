#!/bin/bash

usage_exit() {
    echo "Check the necessary options following."
    echo "-p(profile)"
    echo "-r(region)"
    echo "Option "
    echo "-f(file): Output file of sns topics. If not specified, no file won't be created."
    exit 1
}


while getopts "p:r:f:" OPT
do
    case $OPT in
        p)  profile=$OPTARG
            ;;
        r)  region=$OPTARG
            ;;
        f)  filename=$OPTARG
    esac
done

if [ -n "$profile" ];then
    printf "\e[33;42;1m OK \e[m PROFILE:$profile\n"
else
    printf "\e[33;41;1m NG \e[m profile is not specified\n"
    usage_exit
fi


echo "Output File(-f):"$filename
if [ -e $filename ]; then
    printf "\e[33;41;1m NG \e[m Specified file is already exists.\n"
    exit 1
fi

if [ -n "$region" ];then
    printf "\e[33;42;1m OK \e[m REGION:$region\n"
else
    printf "\e[33;41;1m NG \e[m region is not specified\n"
    usage_exit
fi

CMD="aws sns list-topics --output text --profile $profile --region $region"
echo "CMD:"$CMD
topics=`$CMD | awk '{ print $2 }' | awk -F: '{ print $6 }'`
echo $topics
for topic in $topics; do
   echo $region","$topic | tee -a $filename
done
