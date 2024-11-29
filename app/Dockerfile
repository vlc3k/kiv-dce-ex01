#
# Simple backend demo server image
#

FROM ghcr.io/maxotta/kiv-ds-docker:latest

RUN yum -q -y install python3
RUN pip3 install flask

COPY src /opt/app

CMD /usr/bin/python3 /opt/app/simple-backend.py

# EOF