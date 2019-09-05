FROM alpine:latest
LABEL DOCKERBUILD="docker build -t daverod24/alpine-testing-tools . -f Dockerfile-tools.dockerfile" DOCKERTEST="docker run -it --rm  daverod24/alpine-testing-tools az --version"

RUN \
  apk --update add  vim curl bash py-pip && \
  apk --update add  --virtual=build gcc libffi-dev musl-dev openssl-dev python-dev make && \
  pip  install -U pip && \
  pip  install azure-cli ansible && \
  apk del --purge build
