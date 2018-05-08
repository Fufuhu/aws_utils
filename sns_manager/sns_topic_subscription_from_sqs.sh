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

# Get SQS queue specified.
queues=`aws sqs list-queues --profile $profile --region $region --output text | awk '{ print $2 }'`

for q in $queues; do
    #echo $q
    queue_region=`echo $q | sed -e 's/https:\/\///g' | awk -F. '{ print $1 }'`
    account_id=`echo $q | sed -e 's/https:\/\///g' | awk -F/ '{ print $2}'`
    queue_name=`echo $q | awk -F/ '{ print $NF }'`
    if [ "$queue_name" = "$queue" ]; then
        # Construct the arn identifier from SQS queue URL
        printf "\e[33;42;1m OK \e[m Specified queue($queue) found.\n"
        echo "QUEUE REGION:"$queue_region
        echo "ACCOUNT ID:"$account_id
        echo "QUEUE_NAME:"$queue_name
        queue_arn="arn:aws:sqs:$queue_region:$account_id:$queue_name"
        break
    fi
done

if [ -n "$queue_arn" ]; then
    # If there's queue_arn, OK.
    printf "\e[33;42;1m OK \e[m Queue arn: $queue_arn\n"
else
    # If there's blank queue_arn, NG.
    printf "\e[33;41;1m NG \e[m Queue arn is not identified. Check SQS Queue name.\n"
    exit 1
fi

# awk -F/ '{ print $NF }'

# queue_arn="arn:aws:sqs:$region:$account_id:$queue"
# echo "QUEUE ARN:"$queue_arn

# Get SNS topic specified.
topics=`aws sns list-topics --profile $profile --region $region --output text | awk '{ print $2 }'`

for ta in $topics; do
    topic_name=`echo $ta | awk -F: '{ print $NF }'`    
    if [ "$topic_name" = "$notification" ]; then
        topic_arn=$ta
    fi
done

if [ -n "$topic_arn" ]; then
    printf "\e[33;42;1m OK \e[m Specified topic name(-n), $notification found.\n"
    printf "\e[33;42;1m OK \e[m TOPIC ARN: $topic_arn\n"
else
    printf "\e[33;41;1m NG \e[m Specified topic arn($notification) is not identified. Check SNS topic name(-n).\n"
    exit 1
fi

result=`aws sns subscribe --profile $profile --region $region --output text --topic-arn $topic_arn --protocol sqs --notification-endpoint $queue_arn`
printf "\e[33;42;1m OK \e[m Subscription arn: $result\n"
