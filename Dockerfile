FROM python:3.8-alpine

LABEL "com.github.actions.name"="s3cmd sync action"
LABEL "com.github.actions.description"="Sync a directory with a remote S3 bucket using s3cmd with very useful options like set cache-control and invalidate CloudFront files."
LABEL "com.github.actions.icon"="refresh-cw"
LABEL "com.github.actions.color"="green"

LABEL version="0.1.0"
LABEL repository="https://github.com/thiago.anunciaao/s3cmd-sync-action"
LABEL homepage="https://thiago.anunciacao.com/"
LABEL maintainer="Thiago Anunciação <thiago.anunciacao@me.com>"

# https://github.com/s3tools/s3cmd/blob/master/NEWS

RUN pip install s3cmd

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
