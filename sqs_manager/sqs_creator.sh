#!/bin/bash

usage_exit() {
    echo "Necessary options are not specified."
    echo "Please specifi following options."
    echo "-q(queue name)"
    echo "-r(region)"
    echo "-p(profile)"
    exit 1
}

while getopts "q:p:r:d" OPT
do
    case $OPT in
        q)  queue_name=$OPTARG
            ;;
        p)  profile=$OPTARG
            ;;
        r)  region=$OPTARG
            ;;
        d)  dry_run=true
            ;;
        ?)  usage_exit
            ;;
    esac
done


if [ -n "$queue_name" ]; then
    echo "QUEUE NAME(q):"$queue_name
else
    usage_exit
fi

if [ -n "$region" ]; then
    echo "REGION(r):"$region
else
    usage_exit
fi

if [ -n "$profile" ]; then
    echo "PROFILE(p):"$region
else
    usage_exit
fi

if [ -z $dry_run ]; then
    dry_run=false
fi

echo "DRY RUN(d):"$dry_run

CMD="aws sqs create-queue --queue-name $queue_name --profile $profile --region $region"
if [ "$dry_run" = "false" ]; then
    echo $CMD" execution"
    $CMD
else
    echo "(dry-run):"$CMD
fi