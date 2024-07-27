FROM public.ecr.aws/lambda/python:3.12

COPY requirements.txt  .

RUN  pip install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

COPY lambda_function.py ${LAMBDA_TASK_ROOT}

RUN mkdir .u2net && curl -L https://github.com/danielgatis/rembg/releases/download/v0.0.0/u2net.onnx -o .u2net/u2net.onnx

CMD [ "lambda_function.lambda_handler" ]