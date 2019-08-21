
FROM ubuntu:latest
MAINTAINER daverod24

RUN echo 'root:root' | chpasswd

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y aptitude sudo openssh-server python2.7 git vim curl wget

ADD kotlin-hello-world /tmp/kotlin-hello-world
WORKDIR /tmp/kotlin-hello-world
RUN mkdir -p /root/.ssh_keys/
RUN mkdir -p /root/.ssh/
COPY id_rsa.pub /root/.ssh_keys/
RUN chmod 0400 /root/.ssh_keys/*
RUN cat /root/.ssh_keys/* >> /root/.ssh/authorized_keys
RUN chmod 0400 /root/.ssh/*
RUN mkdir /var/run/sshd
#RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 22 8080

CMD ["/usr/sbin/sshd", "-D"]
