import json
import urllib.request
import os

def lambda_handler(event, context):
    api_url = os.environ['API_URL']

    with urllib.request.urlopen(api_url) as response:
        data = json.loads(response.read().decode())

    print("dummy", data)

    return {
        'statusCode': 200,
        'body': json.dumps(data)
    }
