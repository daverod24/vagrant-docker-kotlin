# vagrant-docker-kotlin
tutorial de vagrant usando docker provider y desplegando un helloworld de kotlin

## El stack formado por Ansible, docker y Vagrant.
Ante los desafíos de construir y mantener un software complejo, es realmente difícil administrar el aprovisionamiento, la orquestación, la construcción y el despliegue de aplicaciones fácilmente. Afortunadamente, hay herramientas y motores que ayudarte.

En el siguiente tutorial, veremos cómo Ansible , Docker y Vagrant se pueden usar para aprovisionar e instalar el software necesario en el entorno en el que puede construir e implementar una aplicación. Una vez configurada, será posible ejecutar la aplicación en cualquier entorno donde estén instalados los requisitos previos.

Aquí hay un resumen rápido sobre las herramientas que vamos a utilizar:

### Ansible
Ansible es un motor de automatización de TI escrito en Python. Con Ansible es posible automatizar el aprovisionamiento, la orquestación, la gestión de la configuración y la implementación de aplicaciones.

Los Playbooks de Ansible se escriben utilizando la sintaxis YAML, de modo que lo tenga en formato legible por humanos y no se requiera un conocimiento complejo para comprender lo que hace. En la práctica, puede pasar sus Playbooks de Ansible a una tercera persona y en un par de minutos él/ella tendrá una idea de cómo administra el aprovisionamiento de su producto.

### Docker
Docker es un buen juguete para construir e implementar cualquier tipo de aplicación en contenedores ligeros de Linux. Es importante comprender que Docker no es una VM. A diferencia de las máquinas virtuales , Docker se basa en AUFS . Comparte el mismo núcleo y sistema de archivos de la máquina donde está alojado. Viene con una gran CLI que hace que la interacción con el motor Docker sea realmente fácil y admite el control de versiones de las imágenes.

### Vagrant
Vagrant es un administrador de máquinas virtuales. Es fácil de configurar y, por defecto, viene con soporte de proveedores como Docker, VirtualBox y VMware. Lo mejor de Vagrant es que puede usar todas las herramientas modernas de aprovisionamiento (por ejemplo, Chef, Puppet, Ansible) para instalar y configurar software en la máquina virtual.

### La meta
- Escriba una API RESTfull que exponga recursos para un hello world.
- Empaquete, compile e implemente una aplicación con Ansible.
- Escriba una imagen acoplable para utilizarla como proveedor de Vagrant.
- Ejecute Vagrant VM, aprovisione con Ansible utilizando el contenedor Docker como proveedor.
- Exponga el punto final HelloWorld al host desde VM.

## Paso 1 (requisito previo): Instalar Vagrant
Instalar Vagrant es fácil, mira la página de descarga y sigue las instrucciones.

Además, necesitamos instalar un complemento que administre el hostsarchivo en la máquina invitada.

```shell
vagrant plugin install vagrant-hostmanager
```

## Paso 2: crear un recurso de Hello World
La API debe ser lo más simple posible y, en aras de la finalidad, utilizamos Spring Boot y escribimos el código en Kotlin . Como nuestro objetivo es demostrar el poder de Ansible, Docker y Vagrant, no entraremos en detalles para construir la API; El código fuente está disponible aquí.

El punto final tiene la siguiente especificación

```kotlin
URL: /hello/:name
HTTP Method: GET

```
## Paso 3: escribir Dockerfile
El Dockerfile va a copiar las fuentes del proyecto para construirlo y desplegarlo. Además, instalamos OpenSSH y exponemos el puerto 8080 para que VM pueda acceder a él.

```docker
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


EXPOSE 22 8080

CMD ["/usr/sbin/sshd", "-D"]

```

El proyecto kotlin-hello-world utilizado en el archivo docker es nuestra fuente de aplicación que creamos en el Paso 1.

## Paso 4: escribir Vagrantfile
Las siguientes cosas están incluidas en el Vagrantfile

Cree una imagen de Docker y úsela como proveedor de VM
Reenvíe el 8080 al 7000 disponible para el host
Aprovisione la máquina con Ansible

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'

Vagrant.configure(2) do |config|

    config.ssh.username = "root"
    config.hostmanager.enabled           = true
    config.hostmanager.manage_guest      = true

    config.ssh.private_key_path = "vagrant_docker/id_rsa"

    config.vm.define "srv" do |v|
      v.vm.provider "docker" do |d|
        d.build_dir = "vagrant_docker"
        d.has_ssh    = true
        d.name = "srv"
        d.remains_running = true
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

```

## Paso 5: Crear un playbook de ansible
El playbook consta de tres roles  
Se configura un archivo requirements.yml para descargar los roles externos.

```yaml
---

- src: geerlingguy.java
- src: gantsign.maven

```


Instalar y configurar Maven se usar roles externos certificados por ansible galaxy
Instalar y configurar Java se usar roles externos certificados por ansible galaxy
Construye e implementa la aplicación hello-world
```yaml
---

- name: Setup environment docker with kotlin example
  hosts: all
  remote_user: root
  become: yes

  roles:
    - role: gantsign.maven
      maven_version: '3.6.1'
      maven_is_default_installation: yes
      maven_fact_group_name: maven

    - role: geerlingguy.java
    - role: hello-world

```



Rol para construir e implementar la aplicación hello-world

```yaml
---

- name: Build the hello-world project
  shell: mvn clean package spring-boot:repackage
  args:
    chdir: /tmp/kotlin-hello-world
  tags: hello-world
  register: mvn_result

- name: "mvn clean task output"
  debug:
   var: mvn_result

- name: Copy
  copy:
   src: ../files/etc/init.d/hello-world.sh
   dest: /etc/init.d/hello-world.sh
   mode: 0775
  tags: java

- name: Run the hello-world
  become: yes
  shell: sh /etc/init.d/hello-world.sh

- name: Using curl get
  shell: curl http://127.0.0.1:8080/hello/esta-es-una-prueba-de-hello-world-de-kotlin-en-vagrant-y-docker
  args:
    warn: no
  ignore_errors: yes
  register: curl_result

- name: "curl clean task output"
  debug:
   var: curl_result.stdout

```
Cree una ssh key y agreguela a el directorio vagrant_docker

```shell 
ssh-keygen -f vagrant_docker/id_rsa -t rsa -C "daverod24@example.com"

```

¡Eso es! Abra la Terminal/Línea de comando y vaya al directorio raíz del proyecto y ejecute

```shell 

vagrant up

```
Tomará un par de minutos antes de que Vagrant inicie e instale el software e implemente la aplicación. Una vez que Vagrant esté en funcionamiento, abra su navegador web favorito y pruebe la siguiente URL:

```shell
curl http://127.0.0.1:7000/hello/<yourname>

```
Como puede ver, es realmente fácil reunir a Ansible, Docker y Vagrant y usar el poder de cada uno para tener una administración de configuración, aprovisionamiento, construcción y despliegue consistentes y fáciles de mantener.