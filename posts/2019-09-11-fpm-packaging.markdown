---
layout: post
title:  "packaging with fpm"
date:   2019-09-11 20:37:02 +0000
categories: packaging, fpm, rpm, deb
---
# packaging with fpm
given: a binary (eg. ./my_binary)

want: create deb and rpm packages of my_binary along with init scripts

instructions:
1. do the packaging inside a docker container

Dockerfile
```
FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive
ARG VERSION

RUN apt-get -y update && apt-get -y install ruby ruby-dev build-essential
RUN gem install --no-ri --no-rdoc fpm pleaserun

WORKDIR /workdir

COPY my_binary /workdir

RUN fpm -v $VERSION -s pleaserun -t dir -n my_binary /usr/bin/my_binary
RUN echo "#!/bin/sh\nsh /usr/share/pleaserun/my_binary/cleanup.sh\nrm -rf /usr/share/pleaserun/my_binary/cleanup.sh\n" > /workdir/my_binary.dir/usr/share/pleaserun/my_binary/delete.sh
RUN fpm -v $VERSION -n my_binary -s dir -t deb --after-install /workdir/my_binary.dir/usr/share/pleaserun/my_binary/install.sh --before-remove /workdir/my_binary.dir/usr/share/pleaserun/my_binary/delete.sh /workdir/my_binary=/usr/bin/ /workdir/my_binary.dir/usr/share/pleaserun/=/usr/share/pleaserun

CMD ["/bin/bash"]
```

2. build docker image like this
```
export VERSION=0.1.0
docker build --build-arg VERSION -f Dockerfile -t fpm_ubuntu /path/to_my_binary/
```

3. copy deb package out
```
docker run -v $PWD:/out -it fpm_ubuntu bash -c "cp *.deb /out"
```

for rpm packages, just replace the -t deb inside the Dockerfile with -t rpm, you'll also want to use centos:7 as your base docker image and install the appropriate yum packages needed for building rpm packages, like rpm-build.

