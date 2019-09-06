# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'

Vagrant.configure(2) do |config|

  # if Vagrant.has_plugin?("vagrant-proxyconf")
  #   config.proxy.http     = "http://10.222.8.100:8080/"
  #   config.proxy.https    = "http://10.222.8.100:8080/"
  #   config.proxy.no_proxy = "localhost,127.0.0.1,.example.com"
  #   config.apt_proxy.http = "http://10.222.8.100:8080/"
  #   config.apt_proxy.https = "DIRECT"
  #   config.docker_proxy.http = "http://10.222.8.100:8080/"
  # end
    # config.ssh.username = "root"
    # config.hostmanager.enabled           = true
    # config.hostmanager.manage_guest      = true

    # config.ssh.private_key_path = "vagrant_docker/id_rsa"
    config.ssh.insert_key = false
    config.ssh.forward_agent = true

    config.vm.define "ubuntu-vagrant-testing" do |v|
      v.vm.provider "docker" do |d|
        d.build_dir = "vagrant_docker"
        d.build_args = ["-t", "daverod24/ubuntu-vagrant-testing"]
        d.dockerfile = "Dockerfile-ubuntu.dockerfile"
        # d.image = "tknerr/baseimage-ubuntu:18.04"
        d.has_ssh    = true
        d.name = "ubuntu-vagrant-testing"
        d.remains_running = true
        # config.ssh.username = "root"
#        d.create_args = ["-p","2202:22","-it", "- privileged"]
      end
    end

    config.vm.hostname = "ansible"
    config.vm.network "forwarded_port", guest: 8080, host: 7000, host_ip: "0.0.0.0", auto_correct: true
    config.vm.provision :hostmanager
    config.vm.provision :ansible do |ansible|
      ansible.playbook      = "vagrant_docker/playbook.yml"
      ansible.become          = true
      ansible.verbose          = "-vvv"
      ansible.galaxy_role_file = "vagrant_docker/requirements.yml"
      ansible.galaxy_command = "ansible-galaxy install -r vagrant_docker/requirements.yml -p ./vagrant_docker/roles"
      ansible.raw_ssh_args = ['-o UserKnownHostsFile=/dev/null']
      ansible.extra_vars = {
        ansible_ssh_user: 'vagrant',
        ansible_connection: 'ssh',
        ansible_ssh_args: '-o ForwardAgent=yes -A',

    }

    end
    config.vm.provision "shell", inline: "echo 'hello docker!'"
end
