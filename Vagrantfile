# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV["LC_ALL"] = "en_US.UTF-8"

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-17.04"
  config.vm.provision :shell, :path => "provision.sh", :privileged => false
  config.vm.network "private_network", ip: "10.20.30.40"
  config.vm.synced_folder "host-share", "/home/ubuntu/host-share"
  config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 1024
    vb.cpus = 1
  end

  config.vm.provider "parallels" do |prl|
    prl.update_guest_tools = true
  end
end
