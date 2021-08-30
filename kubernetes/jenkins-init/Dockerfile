FROM python:3.6.5-alpine
RUN apk update \
    && apk add build-base \
    && pip install pycryptodome
ADD jenkins_home.tar /var/temp/
ADD jenkins-util.tar /
COPY xmlutil /usr/local/bin/
COPY bcrypt /usr/local/bin/
CMD  sh
