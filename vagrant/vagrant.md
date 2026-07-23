Typing `vagrant` from the command line will display a list of all available commands.

Be sure that you are in the same directory as the Vagrantfile when running these commands!

# Creating a VM
- `vagrant init`           -- Initialize Vagrant with a Vagrantfile and ./.vagrant directory, using no specified base image. Before you can do vagrant up, you'll need to specify a base image in the Vagrantfile.
- `vagrant init <boxpath>` -- Initialize Vagrant with a specific box. To find a box, go to the [public Vagrant box catalog](https://app.vagrantup.com/boxes/search). When you find one you like, just replace it's name with boxpath. For example, `vagrant init ubuntu/trusty64`.

# Starting a VM
- `vagrant up`                  -- starts vagrant environment (also provisions only on the FIRST vagrant up)
- `vagrant resume`              -- resume a suspended machine (vagrant up works just fine for this as well)
- `vagrant provision`           -- forces reprovisioning of the vagrant machine
- `vagrant reload`              -- restarts vagrant machine, loads new Vagrantfile configuration
- `vagrant reload --provision`  -- restart the virtual machine and force provisioning

# Getting into a VM
- `vagrant ssh`           -- connects to machine via SSH
- `vagrant ssh <boxname>` -- If you give your box a name in your Vagrantfile, you can ssh into it with boxname. Works from any directory.

# Stopping a VM
- `vagrant halt`        -- stops the vagrant machine
- `vagrant suspend`     -- suspends a virtual machine (remembers state)

# Cleaning Up a VM
- `vagrant destroy`     -- stops and deletes all traces of the vagrant machine
- `vagrant destroy -f`   -- same as above, without confirmation

# Boxes
- `vagrant box list`              -- see a list of all installed boxes on your computer
- `vagrant box add <name> <url>`  -- download a box image to your computer
- `vagrant box outdated`          -- check for updates vagrant box update
- `vagrant box remove <name>`   -- deletes a box from the machine
- `vagrant package`               -- packages a running virtualbox env in a reusable box

# Saving Progress
-`vagrant snapshot save [options] [vm-name] <name>` -- vm-name is often `default`. Allows us to save so that we can rollback at a later time

# Tips
- `vagrant -v`                    -- get the vagrant version
- `vagrant status`                -- outputs status of the vagrant machine
- `vagrant global-status`         -- outputs status of all vagrant machines
- `vagrant global-status --prune` -- same as above, but prunes invalid entries
- `vagrant provision --debug`     -- use the debug flag to increase the verbosity of the output
- `vagrant push`                  -- yes, vagrant can be configured to [deploy code](http://docs.vagrantup.com/v2/push/index.html)!
- `vagrant up --provision | tee provision.log`  -- Runs `vagrant up`, forces provisioning and logs all output to a file

# Plugins
- [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) : `$ vagrant plugin install vagrant-hostsupdater` to update your `/etc/hosts` file automatically each time you start/stop your vagrant box.

# Notes
- If you are using [VVV](https://github.com/varying-vagrant-vagrants/vvv/), you can enable xdebug by running `vagrant ssh` and then `xdebug_on` from the virtual machine's CLI.

# Example

## Подготовка к семинару по Ansible
 
1. Поставьте себе такие пакеты:
* VirtualBox (а также Extension Pack и Guest Additions)
* Vagrant
* Ansible
 
Если работаете на сервере, то эти инструменты уже стоят.
 
2. Поставьте плагин: `vagrant plugin install vagrant-hostmanager`. Этот плагин нужен для того, чтоб машинки имели статические IP внутри сети сервера и мы могли использовать ssh / scp для них. Ansible работает поверх ssh.
3. Создайте любую папку и положите туда этот Vagrantfile:
```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :
 
require 'etc'
 
def form_ips(is_home = "false", num = 0)
    @is_home = is_home.to_s.downcase == "true"
    @header = "10.211."
    if @is_home
        return "%s100.%d" % [@header, 100 + num]
    else
        @suffix = Etc.getlogin[-3..-1].to_i * 3
        return "%s%d.%d" % [@header, @suffix / 256, @suffix % 256 - num]
    end
end
 
@ip1 = form_ips ENV['IS_HOME'], 2
@ip2 = form_ips ENV['IS_HOME'], 1
@ip3 = form_ips ENV['IS_HOME']
puts "This script will start these VMs:"
puts "%s-node1 with IP %s" % [Etc.getlogin, @ip1]
puts "%s-node2 with IP %s" % [Etc.getlogin, @ip2]
puts "%s-node3 with IP %s" % [Etc.getlogin, @ip3]
 
$update_ubuntu = <<SCRIPT
apt update
apt install python-dev python3-dev -y
SCRIPT
 
$update_centos = <<SCRIPT
sudo yum -y install python-devel python3-devel
SCRIPT
 
Vagrant.configure("2") do |config|
  config.hostmanager.enabled = false
  config.hostmanager.manage_guest = true
  config.hostmanager.include_offline = true
  config.hostmanager.ignore_private_ip = false
  config.ssh.forward_agent = true
  config.vm.synced_folder '.', '/vagrant', disabled: true
 
  config.vm.define :node1 do |node1|
    node1.vm.box = "ubuntu/bionic64"
    node1.vm.provider "virtualbox" do |vb|
      vb.cpus = "1"
      vb.memory = "1024"
    end
    node1.vm.network :private_network, ip: @ip1
    node1.vm.hostname = Etc.getlogin + "-node1"
    node1.vm.provision :hostmanager
    node1.vm.provision :shell, :inline => $update_ubuntu
    node1.vm.provision :shell, inline: <<-SHELL
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
      sudo service ssh restart
    SHELL
  end
 
  config.vm.define :node2 do |node2|
    node2.vm.box = "ubuntu/trusty64"
    node2.vm.provider "virtualbox" do |vb|
      vb.cpus = "1"
      vb.memory = "1024"
    end
    node2.vm.network :private_network, ip: @ip2
    node2.vm.hostname = Etc.getlogin + "-node2"
    node2.vm.provision :hostmanager
    node2.vm.provision :shell, :inline => $update_ubuntu
    node2.vm.provision :shell, inline: <<-SHELL
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
      sudo service ssh restart
    SHELL
  end
 
  config.vm.define :node3 do |node3|
    node3.vm.box = "centos/7"
    node3.vm.provider "virtualbox" do |vb|
      vb.cpus = "1"
      vb.memory = "1024"
    end
    node3.vm.network :private_network, ip: @ip3
    node3.vm.hostname = Etc.getlogin + "-node3"
    node3.vm.provision :hostmanager
    node3.vm.provision :shell, :inline => $update_centos
    node3.vm.provision :shell, inline: <<-SHELL
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
      sudo systemctl restart sshd
    SHELL
  end
end
```
4. Запустите создание виртуалок, выполнив в папке с Vagrantfile `vagrant destroy -f && vagrant up`. Команда выполняется долго (~15 минут), поэтому рекомендуется выполнить её до занятия. Также, по возможности поставьте Vagrant локально. Это не сложно особенно если у вас unix-система. Если работаете из домашней машины, запускайте команду так: `vagrant destroy -f && IS_HOME="true" vagrant up`.
 
5. После этого у вас должна появиться возможность заходить на машинки по IP, которые вывелись при запуске `vagrant up`. На всех машинках существует sudo-пользователь vagrant с паролем vagrant.