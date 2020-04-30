# mac 에서 VirtualBox 를 이용한 Kubernetes 설치하기. 

이번에는 Kubernetes 를 kubespray 를 이용하여 설치해 보도록 하겠습니다. 

Minikube 혹은 Docker with kube 를 이용하면 간단히 Mac 에서 활용해 볼 수 있겠으나, 여기서는 실제 VM 혹은 장비를 통해 kubernetes 를 설치하는 것이 목적입니다. 

## VirtualBox 설치하기. 

https://www.virtualbox.org/wiki/Downloads 에서 mac 용 virtualbox 를 다운받고 설치해 줍니다. 

virtualbox 는 여러대의 가상 호스트를 만들어 실제 구축 환경을 실험해 보기에 매우 좋은 툴입니다. 

## Vagrant 다운로드 받기. 

https://www.vagrantup.com/downloads.html 에서 Vagrant 를 다운로드 받습니다. 

Vagrant 는 virtualBox 에 서버를 프로그램을 통해서 설치할 수 있도록 해주는 provisioning 툴입니다. 

이를 이용하면 일일이 한대한대 설치하지 않아도, kubernetes 를 위한 여러대의 virtual host 를 생성해 낼 수 있습니다. 

## Vagrant 설치파일 작성하기. 

vagrant 를 정상적으로 설치하셨다면 이제는 설치 스크립트를 정의할 차례입니다. 

### Vagrantfile 작성하기. 

kubernetes 를 만들어 볼 것이므로 kube_vagrant 라는 디렉토리를 만들고 거기에 Vagrant 파일을 만들겠습니다. 

```
% mkdir kube_vagrant
% cd kube_vagrant 
% vagrant init
```

vagrant init 를 입력하면 Vagrantfile 이 생성됩니다. 

### 프로비저닝 구조 설계하기. 

우리는 일단 마스터 3대, 노드 2대를 설치할 것이기 때문에 다음과 같이 Vagrant 파일을 작성해 줍니다. 

```vagrant
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

```

위 구조를 살펴보면 다음과 같습니다. 

- kube-master01: 쿠버네티스 마스터 1번이 설치 됩니다. ip는 192.168.10.11 이고 22번 접속을 위해서 60011 로 접근합니다. 
- kube-master02: 쿠버네티스 마스터 2번이 설치 됩니다. ip는 192.168.10.12 이고 위와 동일합니다. 
- kube-master03: 쿠버네티스 마스터 3번이 설치 됩니다. ip는 192.168.10.13 이고 위와 동일합니다. 
- kube-node01: 쿠버네티스 노드 1번이 설치됩니다. ip는 192.168.10.21 입니다. 
- kube-node02: 쿠버네티스 노드 2번이 설치됩니다. ip는 192.168.10.22 입니다. 
- ansible-server: kubespray 는 쿠버네티스를 ansible 을 이용하여 설치하기 때문에 kubespray 를 이용하려면 ansible 서버가 한대 필요합니다. 
  사실 로컬에 설치해도 문제 없습니다. 

### vagrant 로 가상호스터 설치하기. 

```
% vagrant up 
```

이렇게 해주면 시간이 오래 걸리지만, vagrant 를 이용하여 각 필요한 호스트를 프로비져닝 하게 됩니다. 

### 기타 vagrant 명령어 

- vagrant up: Vagrantfile 파일을 이용하여 가상 호스트를 설치합니다. 
- vagrant halt: 가상 호스트의 전원을 끕니다. 
- vagrant destroy: 생성한 호스트를 완전히 삭제 합니다. 
- vagrant provision: vagrant 에서 cfg.vm.provision 부분이 변경된경우 이 명령을 수행하면 떠있는 장비에 프로비젼 정보를 갱신해 줍니다. 
- vagrnat ssh host_name: 특정 호스트이름으로 접속합니다. 기본적으로 vagrant를 이용하면 호스트 비번은 vagrant 입니다. 

- vagrant up <config.vm.define 이름>...: 개별적으로 장비를 올리기 위해서 사용합니다. 
- vagrant halt <config.vm.define 이름>...: 개별적으로 장비를 삭제하기 위해서 사용합니다. 
- vagrant destroy <config.vm.define 이름>...: 개별적으로 호스트를 삭제 하기 위해서 사용합니다. 

## 프로비져닝 항목 살펴보기. 

위 vagrant 에서는 provision 수행시 ansible 을 자동 설치 합니다. 

하나하나 살펴 보겠습니다. 

### cfg.vm.provision "shell", path: "bash_ssh_conf_4_CentOS.sh"

위 명령을 살펴보면 프로비저닝이 되면서 shell 을 수행하게 되며 이때 bash_ssh_conf_4_CentOS.sh 라는 쉘이 수행됩니다. 

```
#! /usr/bin/env bash

now=$(date +"%m_%d_%Y")
cp /etc/ssh/sshd_config /etc/ssh/sshd_config_$now.backup
sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd 
```

위와 같이 쉘이 수행이 되며 이 쉘이 하는 일은 다음과 같습니다. 

1. 오늘 날짜를 now 에 할당합니다. 
2. /etc/ssh/sshd_config 파일을 백업합니다. 
3. PasswordAuthentication no 를 PasswordAuthentication yes 로 변경합니다. 
4. 그리고 다시 sshd 를 실행합니다. 

즉 ssh 를 이용할때 비밀번호 인증을 사용할 수 있게 하겠다는 의미입니다. no 가 되면 인증키로만 접속할 수 있게 됩니다. 

여기는 우선 비밀번호 인증을 할 수 있게 바꾸어 줍니다. 

### cfg.vm.provision "shell", inline: "yum install epel-release -y"

ansible 서버를 이용하기 위해서는 epel-release 를 설치해 주어야합니다. 

EPEL(Extra Packages for Enterprise Linux) 를 설치하는 것으로, Fedora Project에서 제공되는 저장소로 각종 패키지의 최신 버전을 제공하는 community 기반의 저장소입니다.

### cfg.vm.provision "shell", inline: "yum install ansible -y"

위 명령어로 ansible 을 설채해 줍니다. 

ansible 을 ansible-server 에만 설치하면 되고, agent 가 필요 없고, 다양한 이점이 있어서 현재 매우 많이 사용하고 있습니다. 

### cfg.vm.provision "file", source: "ansible_env_ready.yml", destination: "ansible_env_ready.yml"

위 명령은 로컬의 ansible_env_read.yml 파일을 host 파일의 user 디렉토리에 ansible_env_ready.yml 파일로 저장하라는 의미입니다. 

ansible_env_ready.yml 파일은 다음과 같습니다. 

```
---
- name: Setup for the Ansible's Environment 
  hosts: localhost
  gather_facts: no 

  tasks:
    - name: Add "/etc/ansible/hosts"
      blockinfile:
          path: /etc/ansible/hosts
          block: |
            [k8s-cluster:children]
            kube-master
            kube-node
            [all]
            master01 ansible_host=192.168.10.11 ip=192.168.10.11
            master02 ansible_host=192.168.10.12 ip=192.168.10.12
            master03 ansible_host=192.168.10.13 ip=192.168.10.13
            node01 ansible_host=192.168.10.21 ip=192.168.10.21
            node02 ansible_host=192.168.10.21 ip=192.168.10.22
            [kube-master]
            master01
            master02
            master03
            [kube-node]
            node01
            node02
            [etcd]
            master01
            master02
            master03
            [calico-rr]
            [vault]
            node01
            node02
    - name: Install sshpass for Authentication
      yum:
        name: sshpass
        state: present 
    - name: Create vim env's directories & files 
      shell: "{{ item }}"
      with_items:
        - "mkdir -p /home/vagrant/.vim/autoload /home/vagrant/.vim/bundle"
        - "touch /home/vagrant/.vimrc"
        - "touch /home/vagrant/.bashrc"
    - name: Install vim-enhancement 
      yum:
        name: vim-enhanced
        state: present 
    - name: Install git 
      yum:
        name: git 
        state: present 
    - name: Download pathogen .vim 
      shell: "curl -fLo /home/vagrant/.vim/autoload/pathogen.vim 
              https://tpo.pe/pathogen.vim"
    - name: Git clone vim-ansible-yaml 
      git:
        repo: https://github.com/chase/vim-ansible-yaml.git 
        dest: /home/vagrant/.vim/bundle/vim-ansible-yaml 
    - name: Configure vimrc 
      lineinfile:
        path: /home/vagrant/.vimrc 
        line: "{{ item }}"
      with_items:
        - "set number"
        - "execute pathogen#infect()"
        - "syntax on"
    - name: Configure Bashrc 
      lineinfile:
        path: /home/vagrant/.bashrc 
        line: "{{ item }}"
      with_items:
        - "alias ans='ansible'"
        - "alias anp='ansible-playbook'"
```

뭔가 매우 많습니다. 하나씩 살펴보면 다음과 같습니다. 

#### ansible 기본구조. 

```
---
- name: Setup for the Ansible's Environment 
  hosts: localhost
  gather_facts: no 

  tasks:
```

ansible 은 첫줄은 --- 으로 시작해야합니다. 이는 공식 ansible 언어인 yaml 을 이용한다는 의미입니다. 

/- 는 배열을 의미하며 - name 라고 했으므로 여러 이름이 배열로 지정할 수 잇다는 의미입니다. 

hosts: 는 ansible 명령이 실행되는 대상이며, localhost 라고 한다면 자기자신 즉, ansible-server 에서 수행된다는 의미입니다. 

gather_facts: no 는 원격 호스트의 여러 fact 값들을 수집한다는 의미지만 no 로 설정합니다. 

tasks: 는 수행될 작업들을 나열하게 됩니다. tasks 아래 나열된 작업들이 각각 수행되면서 대상 호스트에 프로비져닝 하게 됩니다. 

#### tasks 뜯어보기. 

```

    - name: "/etc/ansible/hosts" 에 ansible 사용할 인벤토리를 설정합니다. 
      blockinfile:
          path: /etc/ansible/hosts
          block: |
            [k8s-cluster:children]
            kube-master
            kube-node

            [all]
            master01 ansible_host=192.168.10.11 ip=192.168.10.11
            master02 ansible_host=192.168.10.12 ip=192.168.10.12
            master03 ansible_host=192.168.10.13 ip=192.168.10.13
            node01 ansible_host=192.168.10.21 ip=192.168.10.21
            node02 ansible_host=192.168.10.21 ip=192.168.10.22

            [kube-master]
            master01
            master02
            master03

            [kube-node]
            node01
            node02

            [etcd]
            master01
            master02
            master03

            [calico-rr]

            [vault]
            node01
            node02
```

- blockinfile: 명령어로 아래 내오는 내용 블록을 파일에 쓰라는 의미입니다. 
- path: 는 쓰기를 수행할 대상 파일입니다. 
- block: 은 쓸 내용을 기술합니다. 

ansible 은 작업을 할 대상을 inventory 라고 부릅니다. 그래서 위 내용은 ansible 이 작업 대상으로 생각하는 대상들을 인벤토리 파일에 기술하는 내용입니다. 

```
    - name: ssh 패스워드 인증 프로그램 설치. 
      yum:
        name: sshpass
        state: present 

```

yum을 통해서 sshpass 라는 프로그램을 설치합니다. state: present 는 설치하라는 의미입니다. 삭제하라는 의미는 absent 사용하면 됩니다. 

```
    - name: Create vim env's directories & files 
      shell: "{{ item }}"
      with_items:
        - "mkdir -p /home/vagrant/.vim/autoload /home/vagrant/.vim/bundle"
        - "touch /home/vagrant/.vimrc"
        - "touch /home/vagrant/.bashrc"
    - name: Install vim-enhancement 
      yum:
        name: vim-enhanced
        state: present 
```

위 내용은 vim 을 설치하고 vim 에 대한 환경설정을 하여, 에디터를 이쁘게 해주는 작업입니다. 

사실 안해줘도 됩니다. 

```

    - name: git 설치 
      yum:
        name: git 
        state: present 
    - name: pathogen .vim 을 다운로드하기. 
      shell: "curl -fLo /home/vagrant/.vim/autoload/pathogen.vim 
              https://tpo.pe/pathogen.vim"
    - name: vim-ansible 문법 하일라이트 다운받기 
      git:
        repo: https://github.com/chase/vim-ansible-yaml.git 
        dest: /home/vagrant/.vim/bundle/vim-ansible-yaml 
    - name: vimrc 를 수정하여 vim 이쁘게 꾸미기  
      lineinfile:
        path: /home/vagrant/.vimrc 
        line: "{{ item }}"
      with_items:
        - "set number"
        - "execute pathogen#infect()"
        - "syntax on"
```

git 을 설치합니다. 

그리고 vim 에디터를 꾸며줄 추가적인 하일라이트 기능을 설치합니다. 특히 ansible 에 대해서 문법 하일라이트를 설치해주는 작업을 해주고 있습니다. 

with_items 를 이용하면 반복을 통해서 ansible 이 특정 일을 수행하게 할 수 있습니다. 

```

    - name: Configure Bashrc 
      lineinfile:
        path: /home/vagrant/.bashrc 
        line: "{{ item }}"
      with_items:
        - "alias ans='ansible'"
        - "alias anp='ansible-playbook'"
```

ansible, ansible-playbook 명령어를 자주 이용하게 될 것입니다. 

그러나 매번 ansible, ansible-playbook 을 타이핑하는 것은 불편하니 alias 를 걸어주는 작업을 합니다. 

###     cfg.vm.provision "shell", inline: "ansible-playbook ansible_env_ready.yml"

ansible 을 위한 기본 설정을 shell 을 이용하여 ansible-playbook 을 실행해 줍니다. 이전에 만든 ansible_env_ready.yml 플레이북을 실행해 줍니다. 

이는 vagrant provisioning 시에 미리 실행해 주는 것입니다. 

### cfg.vm.provision "shell", path: "add_ssh_auth.sh", privileged: false

이제 add_ssh_auth.sh 쉘을 실행하여, ansible-server 가 각 hosts 에 ssh 로 접근할 수 있도록 해줍니다. 

쉘의 내용은 다음과 같습니다. 

```
#! /usr/bin/env bash

#ssh key 생성
sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@192.168.10.11
sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@192.168.10.12
sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@192.168.10.13
sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@192.168.10.21
sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@192.168.10.22
```

### 기타 ansible 파일 복사해두기. 

```
cfg.vm.provision "file", source: "auto_ssh_connect.yml", destination: "auto_ssh_connect.yml"
cfg.vm.provision "file", source: "timezone.yml", destination: "timezone.yml"
```

이제는 ssh 연동을 수행하고, 시간을 설정하는 ansible 플레이북을 ansible-server 에 전달해 주는 작업을 해주었습니다. 

auto_ssh_connect.yml

```
---
- name: Automate SSH connections from ansible-server to ansible-client
  hosts: all
  connection: local
  serial: 1
  gather_facts: no
  vars:
      ansible_password: vagrant

  tasks:
      - name: ssh-keyscan for known-hosts
        command: /usr/bin/ssh-keyscan -t ecdsa {{ ansible_host }}
        register: keyscan

      - name: input key
        lineinfile:
            path: ~/.ssh/known_hosts
            line: "{{item}}"
            create: yes
        with_items:
            - "{{keyscan.stdout_lines}}"

      - name: ssh-keygen for authorized_keys
        command: "ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ''"
        ignore_errors: yes
        run_once: true

      - name: input key for each client
        connection: ssh
        authorized_key:
            user: vagrant
            state: present
            key: "{{lookup('file','~/.ssh/id_rsa.pub')}}"
```
위 내용은 ansible-server 가 각 hosts 에 ssh 접속이 암호없이 수행될 수 있도록 인증키를 생성하고, 각 호스트에 복사해주는 작업을 합니다. 

timezone.yml 파일은 다음과 같습니다. 

```
--- 
- name: Setup CentOS timezone 
  hosts: CentOS 
  gather_facts: no 
  become: yes 

  tasks: 
    - name: set timezone to Asia/Seoul 
      timezone: name=Asia/Seoul

```

이것은 각 호스트의 타임존을 Asis/Seoul 로 지정합니다. 

## ansible-server 에 접속하기. 

```
% vagrant ssh ansible-server 
```

위 명령을 접속하고 다음과 같이 플레이북을 실행해 줍니다. 

```
% anp auto_ssh_connect.yml -k
암호: vagrant <-- 입력하기

% anp timezone.yml
```

위와 같이 수행하면 전체 호스트에 ssh 접속 암호없이 수행되며, 시간값도 정상으로 설정이 됩니다. 

## kubespray 로 쿠버네티스 설치하기. 

이제 본격적으로 kubernetes 를 설치할준비가 되었습니다. https://github.com/kubernetes-sigs/kubespray 에 방문합니다. 

### kubespray 체크아웃 받기. 

ansible-server 에서 다음 명령을 수행하빈다. 

```
% git clone https://github.com/kubernetes-sigs/kubespray.git

% cd kubespray
```

이렇게 하고 다음 명령을 수행해 줍니다 .

```
# Install dependencies from ``requirements.txt``
sudo pip3 install -r requirements.txt

# Copy ``inventory/sample`` as ``inventory/mycluster``
cp -rfp inventory/sample inventory/mycluster
```
### mycluster 의 인벤토리 파일 수정하기. 

```
% vim inverntory/mycluster/inventory.ini

```

하고 다음과 같이 내용을 수정해 줍니다. 

```
# ## Configure 'ip' variable to bind kubernetes services on a
# ## different ip than the default iface
# ## We should set etcd_member_name for etcd cluster. The node that is not a etcd member do not need to set the value, or can set the empty string value.
[all]

# ## configure a bastion host if your nodes are not directly reachable
# bastion ansible_host=x.x.x.x ansible_user=some_user
master01 ansible_host=192.168.10.11 ip=192.168.10.11
master02 ansible_host=192.168.10.12 ip=192.168.10.12
master03 ansible_host=192.168.10.13 ip=192.168.10.13
node01 ansible_host=192.168.10.21 ip=192.168.10.21
#node02 ansible_host=192.168.10.21 ip=192.168.10.22

[kube-master]
master01
master02
master03

[etcd]
master01
master02
master03

[kube-node]
node01

[calico-rr]

[k8s-cluster:children]
kube-master
kube-node
```

위 내용은 이전에 본 인벤토리와 거의 동일합니다. 

kube-master, kube-node, etct 등에 대해서만 지정된 주소 값으로 지정해 주면 됩니다. 

### 설치하기. 

위 코드를 저장했다면, 이제 ansible-playbook 을 활용할 때입니다. 

```
% cd /home/vagrant/kubespray
% anp -i inventory/mycluster/inventory.ini --become --become-user=root cluster.yml

```

위 명령을 수행하면 kubernetes 가 각 노드에 설치가 됩니다. 

설치가 왼료되면 ssh 를 종료하고 나갑니다. 

### 설치 확인하기. 

마스터노드 3대에 설치 하였으니 이제는 마스터노드로 접속해야합니다. 

```
% vagrant ssh kube-master01 
% kubectl version 
... 버젼 정보가 나옵니다. 
```

만약 버젼 정보가 나오지 않고 8080 오류가 나온다면 다음과 같이 트러블 수팅을 해줍니다 .

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

위 내용은 kubectl 이 바라보는 마스터노드의 api-server 의 주소를 설정해 주는 것입니다. 

이후 마스터 3대에 모두 지정해주면 정상적으로 kubectl 명령어들이 수행됨을 알 수 있습니다. 

## 결론. 

지금까지 쿠버네티스를 설치해 보았습니다. 

1. virtualBox 를 설치하고. 
2. vagrant 를 이용하여 마스터 3대, 노드 2대, ansible-server 1대를 각각 설치했습니다. 
3. ansible-server 에는 ansible 을 설치하고, 서버에 접속하기 위한 설정, 그리고 git 등을 설치했습니다. 
4. kubespray 를 ansible-server 에 체크아웃 받고, 설치를 위한 inventory 를 작성해 주었습니다. 
5. 그리고 kubespray 를 통해서 kubernetes 를 설치해 주었습니다. 
6. 마지막으로 정상 설치 되었는지 테스트 해 보았고, 약간의 문제를 수정해 주어 정상 확인하였습니다. 

이제 on-prame 에서도 kubernetes 설치할 수 있게 되었습니다. 

