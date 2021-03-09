# Use aws lambda base image
FROM public.ecr.aws/lambda/python:3.8

# Install pip requirements
COPY requirements.txt .
RUN python -m pip install -r requirements.txt

COPY src/* ./

CMD ["app.handler"]
