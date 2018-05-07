#!/bin/bash


usage_exit() {
    echo "Necessary options are not specified."
    echo "-f(file): Specify the file to setup sns topics. file format is csv like 'region,topic-name'"
    echo "-p(profile): Specify the profile to setup sns topics." 
    exit 1
}

while getopts "f:p:d" OPT
do
    case $OPT in
        f)  filename=$OPTARG
            ;;
        p)  profile=$OPTARG
            ;;
        d)  dry_run=true
            ;;
    esac
done


if [ -n "$filename" ]; then
    echo "FILE NAME(-f):"$filename
else
    printf "\e[33;41;1m NG \e[m FILE NAME(-f) is not specified\n"
    usage_exit
fi


if [ -n "$profile" ]; then
    echo "Profile(-p):"$profile
else
    printf "\e[33;41;1m NG \e[m Profile(-p) is not specified\n"
    usage_exit
fi

if [ -z $dry_run ]; then
    dry_run=false
fi

echo "Dry-run:"$dry_run

cat $filename | while read line
do
    region=`echo $line | awk -F, '{ print $1 }'`
    topic=`echo $line | awk -F, '{ print $2 }'`
    CMD="aws sns create-topic --name $topic --region $region --profile $profile"
    echo "REGION:$region TOPIC:$topic CMD:$CMD"
    if [ "$dry_run" = "false" ]; then
        $CMD
    else
        echo "(dry-run)"$CMD
    fi
    if [ $? -eq 0 ]; then
        printf "$(date +%Y/%m/%d:%H:%M:%S) \e[33;42;1m OK \e[m $CMD successed.\n"
    fi
done