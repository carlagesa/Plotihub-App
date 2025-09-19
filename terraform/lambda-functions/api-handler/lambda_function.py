import json
import os

print('Loading function')

def lambda_handler(event, context):
    """
    Handles incoming API requests.
    """
    print('Received event: ' + json.dumps(event, indent=2))

    response = {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'message': "Hello from the multi-region API (powered by Python)!",
            # In a real app, you would use this environment variable to connect to the proxy
            # 'databaseEndpoint': os.environ.get('RDS_PROXY_ENDPOINT')
        })
    }

    return response