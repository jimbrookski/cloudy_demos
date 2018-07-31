import json
import argparse
import sys

# Build arguments
parser = argparse.ArgumentParser(description='Parse JSON from template validation for success')
parser.add_argument("validation_response", type=str, help="JSON string of validation response")
parser.add_argument("template", type=str, help="Resource group name that was tested against")
args = parser.parse_args()

print("Parsing validation for template {}".format(args.template))

try:
    response = json.loads(args.validation_response)
except ValueError:
    print('##vso[task.logissue type=error;] Invalid JSON result from validation test.')
    print('##vso[task.complete result=Failed;]DONE')
    sys.exit(1)

if response is not None:
    if 'properties' in response and response['properties'] is not None: 
        if response['properties']['provisioningState'] == 'Succeeded':
            print('Template validation succeeded for template {}'.format(args.template))
            
            validated_resources = response['properties']['validatedResources']
            print('The following resources will be provisioned in {}'.format(args.template))
            for resource in validated_resources:
                print('{} of type {}'.format(resource['name'], resource['type']))
    elif 'error' in response:
        print('##vso[task.logissue type=error;code={};] {}'.format(response['error']['code'], response['error']['message']))
        print('##vso[task.complete result=Failed;]DONE')
        sys.exit(1)
    else:
        print('##vso[task.logissue type=error;] Template validation failed for unknown reason')
        print('##vso[task.complete result=Failed;]DONE')
        sys.exit(1)
else:
    print('##vso[task.logissue type=error;] Template validation failed for unknown reason')
    print('##vso[task.complete result=Failed;]DONE')
    sys.exit(1)
