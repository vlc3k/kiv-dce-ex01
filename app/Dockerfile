#
# Simple backend demo server image
#

FROM python:3

COPY src /opt/app
WORKDIR /opt/app

RUN pip install flask

CMD ["python", "/opt/app/app.py"]

# EOF