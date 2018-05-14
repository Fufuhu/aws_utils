#! /usr/bin/env python
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

elb = session.client('elbv2')

target_groups=elb.describe_target_groups()
# print(target_groups)



script_dir=os.path.dirname(os.path.abspath(__file__))
# print(script_dir)

env = Environment(loader=FileSystemLoader(script_dir+"/templates/"))
template = env.get_template('target_groups.md.j2')
rendered = template.render(target_groups)

# print(str(rendered))

output_dir=script_dir+"/exports/"

try:
    file = open(output_dir+'target_gropus.md', 'w')
    file.write(str(rendered))
except Exception as e:
    print(e)
finally:
    file.close()
