#!/bin/bash -x

export AWS_REGION="${region}"

OWNER="${owner}"
PROJECT="${project}"
ENVIRONMENT="${environment}"
RESOURCE_ID="${resource_id}"
NAME="${name}"

echo "Start Date: `date`"

echo " Owner is $OWNER "
echo " Project is $PROJECT "
echo " Environment is $ENVIRONMENT "
echo " Resource_Id is $RESOURCE_ID "

#Tags the autoscaling group
echo "Creating tags for ASG with id $RESOURCE_ID"
aws autoscaling create-or-update-tags --tags ResourceId=$RESOURCE_ID,ResourceType=auto-scaling-group,Key=Owner,Value="$OWNER",PropagateAtLaunch=true \
                                             ResourceId=$RESOURCE_ID,ResourceType=auto-scaling-group,Key=Project,Value="$PROJECT",PropagateAtLaunch=true \
                                             ResourceId=$RESOURCE_ID,ResourceType=auto-scaling-group,Key=Environment,Value="$ENVIRONMENT",PropagateAtLaunch=true 
#Creates a list called EC2_LIST which has the instance's ids
EC2_LIST=$(aws ec2 describe-instances --filter Name=tag:aws:autoscaling:groupName,Values=$RESOURCE_ID | grep InstanceId | cut -d ":" -f2 | sed s/,//g | sed s/\"//g)

#Tags the instances
for instance in $EC2_LIST; do 
    echo "Tagging the instance with id $instance"
    aws ec2 create-tags --resources $instance --tags Key=Owner,Value="$OWNER"
    aws ec2 create-tags --resources $instance --tags Key=Project,Value="$PROJECT"
    aws ec2 create-tags --resources $instance --tags Key=Environment,Value="$ENVIRONMENT"
    aws ec2 create-tags --resources $instance --tags Key=Name,Value="$NAME"
done



