# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
 
  # KubeMaster 01
  config.vm.define "kube-master01" do |cfg| 
    cfg.vm.box = "centos/7"
    cfg.vm.provider "virtualbox" do |vb|
      vb.name = "kube-master01"
    end
    
    cfg.vm.host_name = "kube-master01"
    cfg.vm.network "public_network", ip: "192.168.10.11", bridge: "en0: Wi-Fi (AirPort)"
    cfg.vm.network "forwarded_port", guest: 22, host: 60011, auto_correct: true, id: "ssh"
    cfg.vm.synced_folder ".", "/shared/data", disabled: true 
    cfg.vm.provision "shell", path: "bash_ssh_conf_4_CentOS.sh"
  end
 
  # KubeMaster 02
  config.vm.define "kube-master02" do |cfg| 
    cfg.vm.box = "centos/7"
    cfg.vm.provider "virtualbox" do |vb|
      vb.name = "kube-master02"
    end
    
    cfg.vm.host_name = "kube-master02"
    cfg.vm.network "public_network", ip: "192.168.10.12", bridge: "en0: Wi-Fi (AirPort)"
    cfg.vm.network "forwarded_port", guest: 22, host: 60012, auto_correct: true, id: "ssh"
    cfg.vm.synced_folder ".", "/shared/data", disabled: true 
    cfg.vm.provision "shell", path: "bash_ssh_conf_4_CentOS.sh"
  end
 
  # KubeMaster 03
  config.vm.define "kube-master03" do |cfg| 
    cfg.vm.box = "centos/7"
    cfg.vm.provider "virtualbox" do |vb|
      vb.name = "kube-master03"
    end
    
    cfg.vm.host_name = "kube-master03"
    cfg.vm.network "public_network", ip: "192.168.10.13", bridge: "en0: Wi-Fi (AirPort)"
    cfg.vm.network "forwarded_port", guest: 22, host: 60013, auto_correct: true, id: "ssh"
    cfg.vm.synced_folder ".", "/shared/data", disabled: true 
    cfg.vm.provision "shell", path: "bash_ssh_conf_4_CentOS.sh"
  end
 
  # KubeNode 01
  config.vm.define "kube-node01" do |cfg| 
    cfg.vm.box = "centos/7"
    cfg.vm.provider "virtualbox" do |vb|
      vb.name = "kube-node01"
    end
    
    cfg.vm.host_name = "kube-node01"
    cfg.vm.network "public_network", ip: "192.168.10.21", bridge: "en0: Wi-Fi (AirPort)"
    cfg.vm.network "forwarded_port", guest: 22, host: 60021, auto_correct: true, id: "ssh"
    cfg.vm.synced_folder ".", "/shared/data", disabled: true 
    cfg.vm.provision "shell", path: "bash_ssh_conf_4_CentOS.sh"
  end

  # KubeNode 02
  config.vm.define "kube-node02" do |cfg| 
    cfg.vm.box = "centos/7"
    cfg.vm.provider "virtualbox" do |vb|
      vb.name = "kube-node02"
    end
    
    cfg.vm.host_name = "kube-node02"
    cfg.vm.network "public_network", ip: "192.168.10.22", bridge: "en0: Wi-Fi (AirPort)"
    cfg.vm.network "forwarded_port", guest: 22, host: 60022, auto_correct: true, id: "ssh"
    cfg.vm.synced_folder ".", "/shared/data", disabled: true 
    cfg.vm.provision "shell", path: "bash_ssh_conf_4_CentOS.sh"
  end

  # Ansible Server 
  config.vm.define "ansible-server" do |cfg|
    cfg.vm.box = "centos/7"
    cfg.vm.provider "virtualbox" do |vb|
      vb.name = "ansible-Server"
    end

    cfg.vm.host_name = "ansible-server"
    cfg.vm.network "public_network", ip: "192.168.10.10", bridge: "en0: Wi-Fi (AirPort)"
    cfg.vm.network "forwarded_port", guest: 22, host: 60000, auto_correct: true, id: "ssh"
    cfg.vm.synced_folder ".", "/vagrant", disabled: true
    cfg.vm.provision "shell", inline: "yum install epel-release -y"
    cfg.vm.provision "shell", inline: "yum install ansible -y"
    cfg.vm.provision "file", source: "ansible_env_ready.yml", destination: "ansible_env_ready.yml"
    cfg.vm.provision "shell", inline: "ansible-playbook ansible_env_ready.yml"
    cfg.vm.provision "shell", path: "add_ssh_auth.sh", privileged: false
    cfg.vm.provision "file", source: "auto_ssh_connect.yml", destination: "auto_ssh_connect.yml"
    cfg.vm.provision "file", source: "timezone.yml", destination: "timezone.yml"
  end
  
end

