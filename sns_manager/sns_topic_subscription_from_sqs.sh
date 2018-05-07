#!/bin/bash


# SQSキュー名とアカウントID、リージョン名からARNを取得

while getopts "p:q:r:n:d" OPT
do
    case $OPT in
        p)  profile=$OPTARG
            ;;
        q)  queue=$OPTARG
            ;;
        n)  notification=$OPTARG
            ;;
        r)  region=$OPTARG
            ;;
        d)  dry_run=true
            ;;
    esac
done

echo "PROFILE(-p):"$profile

echo "QUEUE NAME(-q):"$queue

echo "SNS TOPIC NAME(-n):"$notification

queues=`aws sqs list-queues --profile $profile --output text | awk '{ print $2 }'`

for q in $queues; do
    #echo $q
    queue_region=`echo $q | sed -e 's/https:\/\///g' | awk -F. '{ print $1 }'`
    account_id=`echo $q | sed -e 's/https:\/\///g' | awk -F/ '{ print $2}'`
    queue_name=`echo $q | awk -F/ '{ print $NF }'`
    if [ "$queue_name" = "$queue" ]; then
        printf "\e[33;42;1m OK \e[m Specified queue($queue) found.\n"
        echo "QUEUE REGION:"$queue_region
        echo "ACCOUNT ID:"$account_id
        echo "QUEUE_NAME:"$queue_name
        queue_arn="arn:aws:sqs:$queue_region:$account_id:$queue_name"
        break
    fi
done

if [ -n "$queue_arn" ]; then
    printf "\e[33;42;1m OK \e[m Queue arn: $queue_arn\n"
else
    printf "\e[33;41;1m NG \e[m Queue arn is not identified. Check SQS Queue name.\n"
fi

# awk -F/ '{ print $NF }'

# queue_arn="arn:aws:sqs:$region:$account_id:$queue"
# echo "QUEUE ARN:"$queue_arn