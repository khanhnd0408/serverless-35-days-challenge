import os
import io
import zipfile
import pooch


def download_file(client, bucket, input_object_title):
    data_stream = io.BytesIO()
    client.download_fileobj(bucket, input_object_title, data_stream)
    return data_stream


def init_lib(client, bucket, input_object_title, pkgdir, tempdir):
    data_stream = download_file(client, bucket, input_object_title)

    zipfile.ZipFile(data_stream.read(), 'r').extractall(tempdir)
    os.rename(tempdir, pkgdir)  # Atomic


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

        init_lib(client, bucket, input_object_title, pkgdir, tempdir)
        init_model()
