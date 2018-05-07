#!/bin/bash


usage_exit() {
    echo "Necessary options are not specified."
    echo "-r(region)"
    exit 1
}

cur_dir=`pwd`
echo "CURRENT_DIR:"$cur_dir
cd `dirname $0`
script_dir=`pwd`
echo "SCRIPT_DIR:"$script_dir
cd $cur_dir

while getopts "p:r:f:t:d" OPT
do
    case $OPT in
        p)  profile=$OPTARG
            ;;
        r)  region=$OPTARG
            ;;
        d)  dry_run=true
            ;;
        f)  filename=$OPTARG
            ;;
        ?)  usage_exit
            ;;
    esac
done

if [ -n "$profile" ]; then
    echo "PROFILE: "$profile
else
    echo "PROFILE is not specified. Use default profile."
    echo "PROFILE: default"
fi

if [ -n "$region" ]; then
    echo "REGION:" $region
else
    echo "REGION(-r) is not specified."
    usage_exit
fi

if [ -n "$filename" ]; then
    echo "OUTPUT(-f):"$filename
else
    echo "OUTPUT(-f) is not specified. Use the default."
    filename=$profile"_"$region"_"`echo $RANDOM`
    echo "OUTPUT(-f):"$filename
fi

if [ -z $dry_run ]; then
    dry_run=false
fi

CMD="aws sqs list-queues --region=$region --profile=$profile --output=text"
# awk '{ print $2 }' | awk -F '/' '{ print $5 }' | sed -e 's/dev/prod/g'"

if [ "$dry_run" = "false" ]; then
    queues=`$CMD | awk '{ print $2 }' | awk -F '/' '{ print $5 }'`
    for line in $queues; do
        echo $region","$line | tee -a $filename
    done
else
    echo "(dry-run):"$CMD
fi
