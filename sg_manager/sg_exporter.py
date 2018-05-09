import os
import argparse

from boto3.session import Session
from jinja2 import Environment, FileSystemLoader, Template


parser = argparse.ArgumentParser(
    prog='alb target groups exporter',
    usage='Export target groups for application loadbalancers.',
    description='Export and documentate the target groups for Application Loadbalancers',
    add_help=True
)

parser.add_argument('-r', '--region', required=True)
parser.add_argument('-p', '--profile')

args = parser.parse_args()


if args.profile:
    profile = args.profile
else:
    profile = 'default'

if args.region:
    region = args.region
session = Session(profile_name=profile, region_name=region)

ec2 = session.client('ec2')

security_groups = ec2.describe_security_groups()

#print(str(security_groups)) 

script_dir=os.path.dirname(os.path.abspath(__file__))
print(script_dir)

env = Environment(loader=FileSystemLoader(script_dir+"/templates/"))
template = env.get_template('security_groups.md.j2')
rendered = template.render(security_groups)

print(str(rendered))