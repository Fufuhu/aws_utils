import os
import json
import argparse

from boto3.session import Session
from jinja2 import Environment, FileSystemLoader, Template
from pprint import pprint

class TemplateRenderer():
    def render(self, prefix, parameters, path=os.path.dirname(os.path.abspath(__file__))+'/templates/'):
        env = Environment(loader=FileSystemLoader(path))
        template = env.get_template(prefix+'.md.j2')
        rendered = template.render(parameters)
        return rendered
    
    def export(self, prefix, parameters, filename, path=os.path.dirname(os.path.abspath(__file__))):
        rendered = self.render(prefix, parameters)
        try:
            file = open(path+'/exports/'+prefix+'_'+filename+'.md', 'w')
            file.write(str(rendered))
        except Exception as e:
            print(e)
        finally:
            file.close()
        return rendered


parser = argparse.ArgumentParser(add_help=True)

# parser.add_argument('-r', '--region', required=True)
parser.add_argument('-p', '--profile', required=True)


args = parser.parse_args()

session = Session(profile_name=args.profile)
s3 = session.client('s3')



bs = s3.list_buckets().get('Buckets')
bucket_names = []
for bucket in bs:
    if bucket.get('Name'):
        bucket_names.append(bucket.get('Name'))

policies = []
for bucket_name in bucket_names:
    try:
        policy = s3.get_bucket_policy(Bucket=bucket_name).get('Policy')
    except:
        policy = None
    policies.append({
        'Name': bucket_name,
        # 'Policy': json.dumps(policy, indent=4, sorted_keys=True),
        'Policy': policy,
    })


renderer = TemplateRenderer()
renderer.export(
    prefix='buckets',
    parameters={
        'Policies': policies,
    },
    filename=args.profile
)

