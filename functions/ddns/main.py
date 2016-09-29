"""
Lambda func doing ASG DDNS
"""

import json
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def update_route53(route53,hostedzoneid,source,target):
	r53_response = route53.change_resource_record_sets(
	HostedZoneId= hostedzoneid,
	ChangeBatch= {
					'Changes': [
						{
						 'Action': 'UPSERT',
						 'ResourceRecordSet': {
							 'Name': source,
							 'Type': 'A',
							 'TTL': 300,
							 'ResourceRecords': [{'Value': target}]
						}
					}]
	})

def handle(event, context):
    logger.info(json.dumps(event))
    
    autoscaling = boto3.client("autoscaling")
    ec2 = boto3.client("ec2")
    route53 = boto3.client("route53")
    
    message = json.loads(event["Records"][0]["Sns"]["Message"])
    asg_name = message["AutoScalingGroupName"]
    asg_event = message["Event"]
    
    logger.info("Getting Tags")
    as_response = autoscaling.describe_tags(
        Filters=[
        {
        "Name": "auto-scaling-group",
        "Values": [asg_name],
        },
        {
        "Name": "key",
        "Values": ["DomainMeta"],
        }
        ],
        MaxRecords=1
    )
    
    logger.info("Processing ")
    if len(as_response["Tags"]) is 0:
        logger.error("ASG: {} does not define Route53 DomainMeta tag".format(asg_name))
    else:
        tokens = as_response["Tags"][0]["Value"].split(":")
        route53tags = {
        "HostedZoneId": tokens[0],
        "ZoneName": tokens[1]
        }
        
    logger.info("Found tags:")    
    logger.info(json.dumps(route53tags))
    logger.info("Retrieving Instances in ASG")
    as_response = autoscaling.describe_auto_scaling_groups(
        AutoScalingGroupNames=[asg_name],
        MaxRecords=1
    )
    instanceIds = []
    for instance in as_response["AutoScalingGroups"][0]["Instances"]:
        instanceIds.append(instance["InstanceId"])
    
    ec2_response = ec2.describe_instances(InstanceIds=instanceIds)
    
    for index, reservation in enumerate(ec2_response["Reservations"]):
        logger.info("ASG Instance Private IP:{}".format(reservation["Instances"][0]["NetworkInterfaces"][0]["PrivateIpAddress"]))
        update_route53(route53,route53tags["HostedZoneId"],"s"+str(index+1)+"."+route53tags["ZoneName"],reservation["Instances"][0]["NetworkInterfaces"][0]["PrivateIpAddress"])
    
