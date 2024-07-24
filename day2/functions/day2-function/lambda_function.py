import boto3
import io
import sys
import os
import zipfile
import pooch
import shutil

os.environ["U2NET_HOME"] = "/tmp/.u2net"

def download_file(client, bucket, input_object_title):
    data_stream = io.BytesIO()
    client.download_fileobj(bucket, input_object_title, data_stream)
    data_stream.seek(0)
    return data_stream


def init_lib(client, bucket, input_object_title, pkgdir, tempdir):
    data_stream = download_file(client, bucket, input_object_title)

    zipfile.ZipFile(data_stream, 'r').extractall(tempdir)
    shutil.copytree(tempdir, pkgdir)  # Atomic


def init_model():
    pooch.retrieve(
        "https://github.com/danielgatis/rembg/releases/download/v0.0.0/u2net.onnx",
        ("md5:60024c5c889badc19c04ad937298a77b"),
        fname="u2net.onnx",
        path=os.path.expanduser('~/.u2net'),
        progressbar=True,
    )


def init(client, bucket, input_object_title, pkgdir):
    if not os.path.exists(pkgdir):
        tempdir = '/tmp/_temp-python'
        os.makedirs(tempdir, exist_ok=True)

        init_lib(client, bucket, input_object_title, '/opt/python', tempdir)
        init_model()


pkgdir = '/tmp/python'
sys.path.insert(1, pkgdir)
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    print("event", event)
    items = [{"bucket": record["s3"]["bucket"]["name"], "object": record["s3"]["object"]["key"]} for record in event["Records"]]

    bucket = items[0]["bucket"]
    input_object_title = items[0]["object"]
    output_object_title = input_object_title.replace("input", "output")

    init(s3_client, bucket, "lib.zip", pkgdir)

    data_stream = io.BytesIO()
    s3_client.download_fileobj(bucket, input_object_title, data_stream)

    data_stream.seek(0)

    from rembg import remove
    output = remove(data_stream.read())

    s3_client.upload_fileobj(io.BytesIO(output), bucket, output_object_title)

    return {
        'statusCode': 200,
    }
