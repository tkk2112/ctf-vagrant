# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision :shell, :path => "../docker/setup.sh", :privileged => false
  config.vm.network "private_network", ip: "10.20.30.40"
  config.vm.synced_folder "host-share", "/home/ubuntu/host-share"

  config.vm.provider "parallels" do |prl|
    prl.update_guest_tools = true
  end
end
