
FROM ubuntu:latest
LABEL NAME="daverod24"
LABEL DOCKERBUILD="docker build -t daverod24/ubuntu-vagrant-testing . -f Dockerfile-tools.dockerfile" DOCKERTEST="docker run -it --rm  daverod24/ubuntu-vagrant-testing az --version"


RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y sudo python2.7 git vim curl wget

ADD kotlin-hello-world /tmp/kotlin-hello-world
WORKDIR /tmp/kotlin-hello-world
# RUN mkdir -p /root/.ssh_keys/
# RUN mkdir -p /root/.ssh/
# COPY id_rsa.pub /root/.ssh_keys/
# RUN chmod 0400 /root/.ssh_keys/*
# RUN cat /root/.ssh_keys/* >> /root/.ssh/authorized_keys
# RUN chmod 0400 /root/.ssh/*
# RUN mkdir /var/run/sshd

EXPOSE 22 8080

CMD ["/usr/sbin/sshd", "-D"]
