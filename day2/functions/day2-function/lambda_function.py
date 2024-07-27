import os
import io
import boto3
from rembg import remove

os.environ["U2NET_HOME"] = "/var/task/.u2net"
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    items = [{"bucket": record["s3"]["bucket"]["name"], "object": record["s3"]["object"]["key"]} for record in event["Records"]]

    bucket = items[0]["bucket"]
    input_object_title = items[0]["object"]
    output_object_title = input_object_title.replace("input", "output")

    data_stream = io.BytesIO()
    s3_client.download_fileobj(bucket, input_object_title, data_stream)

    data_stream.seek(0)

    output = remove(data_stream.read())

    s3_client.upload_fileobj(io.BytesIO(output), bucket, output_object_title)

    return {
        'statusCode': 200,
    }
