FROM alpine
MAINTAINER cmp@tongtech.com
LABEL helm.version=3.4.0
ADD helm-push.tar .
COPY helm-script/ .
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk update && apk add curl &&  rm -rf /var/cache/apk/* \
    && curl -o helm.tar.gz https://get.helm.sh/helm-v3.4.0-linux-amd64.tar.gz \
    && tar -zxvf helm.tar.gz -C . \
    && rm -f helm.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && helm plugin add helm-push
ENTRYPOINT ./entrypoint.sh

