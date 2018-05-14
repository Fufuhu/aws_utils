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


sqs = session.client('sqs')
queues = sqs.list_queues().get('QueueUrls')


print(queues)


renderer = TemplateRenderer()
renderer.export(
    prefix='sqs',
    parameters={
        'queues': queues,
    },
    filename=args.profile
)

