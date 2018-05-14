import os
import argparse

from boto3.session import Session
from jinja2 import Environment, FileSystemLoader, Template

class TemplateRenderer():
    def render(self, prefix, parameters, path=os.path.dirname(os.path.abspath(__file__))+'/templates/'):
        env = Environment(loader=FileSystemLoader(path))
        template = env.get_template(prefix+'.md.j2')
        rendered = template.render(parameters)
        return rendered
    
    def export(self, prefix, parameters, path=os.path.dirname(os.path.abspath(__file__))):
        rendered = self.render(prefix, parameters)
        try:
            file = open(path+'/exports/'+prefix+'.md', 'w')
            file.write(str(rendered))
        except Exception as e:
            print(e)
        finally:
            file.close()
        return rendered


parser = argparse.ArgumentParser(add_help=True)

parser.add_argument('-r', '--region', required=True)
parser.add_argument('-p', '--profile', required=True)

args = parser.parse_args()

session = Session(profile_name=args.profile, region_name=args.region)

render_settings = []

ec2 = session.client('ec2')
instances = ec2.describe_instances()

render_settings.append(
    {
        "prefix": instances,
        "parameters": instances,
    }
)



renderer = TemplateRenderer()

for setting in render_settings:
    rendered = renderer.export(prefix=setting.get('prefix'), parameters=setting.get('parameters'))
