# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'

Vagrant.configure(2) do |config|

    config.ssh.username = "root"
    config.hostmanager.enabled           = true
    config.hostmanager.manage_guest      = true

    config.ssh.private_key_path = "id_rsa"

    config.vm.define "srv" do |v|
      v.vm.provider "docker" do |d|
        d.build_dir = "vagrant_docker"
 #       d.build_args = ["-t", "srv"]
        d.has_ssh    = true
        d.name = "srv"
        d.remains_running = true
#        d.create_args = ["-p","2202:22","-it", "— privileged"]
      end
    end

    config.vm.hostname = "ansible"
    config.vm.network "forwarded_port", guest: 8080, host: 7000, host_ip: "0.0.0.0", auto_correct: true
    config.vm.provision :hostmanager
    config.vm.provision :ansible do |ansible|
      ansible.playbook      = "vagrant_docker/playbook.yml"
      ansible.become          = true
      ansible.verbose          = "-vv"
      ansible.galaxy_role_file = "vagrant_docker/requirements.yml"
      ansible.galaxy_command = "ansible-galaxy install -r vagrant_docker/requirements.yml -p ./vagrant_docker/roles"

    end

end
