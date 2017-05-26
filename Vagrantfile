# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
  config.vm.network "forwarded_port", guest: 9999, host: 9999, auto_correct: true
  config.vm.provision "shell", path: "scripts/bootstrap.sh"
end
