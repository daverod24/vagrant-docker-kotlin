FROM ubuntu:latest
LABEL NAME="daverod24"
LABEL DOCKERBUILD="docker build -t daverod24/ubuntu-vagrant-testing . -f Dockerfile-ubuntu.dockerfile" DOCKERTEST="docker run -it --rm  daverod24/ubuntu-vagrant-testing az --version"

# ENV HTTP_PROXY="http://10.222.8.100:8080/"
# ENV HTTPS_PROXY="http://10.222.8.100:8080/"
# ENV NO_PROXY=localhost,127.0.0.1
# ENV http_proxy="http://10.222.8.100:8080/"
# ENV https_proxy="http://10.222.8.100:8080/"
# ENV no_proxy=localhost,127.0.0.1


ENV DEBIAN_FRONTEND noninteractive

# install common dependencies
RUN apt-get update && apt-get install -y \
    locales \
    curl \
    lsb-release \
    openssh-server \
    sudo \
    aptitude \
    python-dev \
    python \
    python-pip


RUN  pip  install azure-cli ansible
    #  pip  install -U pip


# ensure we have the en_US.UTF-8 locale available
RUN locale-gen en_US.UTF-8

# setup the vagrant user
RUN if ! getent passwd vagrant; then useradd -d /home/vagrant -m -s /bin/bash vagrant; fi \
    && echo vagrant:vagrant | chpasswd \
    && echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir -p /etc/sudoers.d \
    && echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/vagrant \
    && chmod 0440 /etc/sudoers.d/vagrant

# add the vagrant insecure public key
RUN mkdir -p /home/vagrant/.ssh \
    && chmod 0700 /home/vagrant/.ssh \
    && wget --no-check-certificate \
      https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub \
      -O /home/vagrant/.ssh/authorized_keys \
    && chmod 0600 /home/vagrant/.ssh/authorized_keys \
    && chown -R vagrant /home/vagrant/.ssh

# don't clean packages, we might be using vagrant-cachier
RUN rm /etc/apt/apt.conf.d/docker-clean

# create the privilege separation directory for sshd
RUN mkdir -p /run/sshd

ADD kotlin-hello-world /tmp/kotlin-hello-world
WORKDIR /tmp/kotlin-hello-world

EXPOSE 22 8080

# run sshd in the foreground
CMD /usr/sbin/sshd -D \
    -o UseDNS=no\
    -o UsePAM=no\
    -o PasswordAuthentication=yes\
    -o PidFile=/tmp/sshd.pid
