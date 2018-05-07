#!/bin/bash

usage_exit() {
    echo "Usage is following."
    echo "-f(filename): source file to create queues."
    echo "-p(profile)"
    echo "File format must be csv like 'region, queuename'"
    exit 1
}

cur_dir=`pwd`
echo "CURRENT_DIR:"$cur_dir
cd `dirname $0`
script_dir=`pwd`
echo "SCRIPT_DIR:"$script_dir
cd $cur_dir

while getopts "p:f:d" OPT
do
    case $OPT in
        f)  filename=$OPTARG
            ;;
        p)  profile=$OPTARG
            ;;
        d)  dry_run=true
            ;;
        ?)  usage_exit
            ;;
    esac
done

if [ -n "$filename" ]; then
    echo "INPUT FILENAME:"$filename
else
    echo "-f(filename) is not specified."
    usage_exit
fi

if [ -n "$profile" ]; then
    echo "PROFILE:"$profile
else
    echo "-p(profile) is not specified."
    usage_exit
fi

if [ -z $dry_run ]; then
    dry_run=false
fi

echo "DRY RUN(d):"$dry_run


cat $filename | while read line
do
    region=`echo $line | awk -F, '{ print $1 }'`
    queue=`echo $line | awk -F, '{print $2}'`
    echo "REGION:"$region" QUEUE:"$queue" PROFILE:"$profile
    CMD="$script_dir/sqs_creator.sh -q $queue -p $profile -r $region"
    if [ "$dry_run" = "true" ]; then
        CMD=$CMD" -d"
    fi
    echo "COMMAND:"$CMD
    $CMD
done