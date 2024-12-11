# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# Chargement des variables d'environnement depuis le fichier .env 
unless Vagrant.has_plugin?("vagrant-env")
  system('vagrant plugin install vagrant-env')
  puts "Plugin vagrant-env installé. Relance de 'vagrant up'..."
  exit system('vagrant', *ARGV)
end

# Lecture de la configuration depuis le fichier YAML
config_file = File.join(File.dirname(__FILE__), 'config.yml')
settings = File.exist?(config_file) ? YAML.load_file(config_file) : {
  "box" => "ubuntu/focal64",
  "hostname" => "vagrant",
  "private_ip" => "192.168.33.10", 
  "cpus" => "2",
  "memory" => "2048"
}

# Configuration Vagrant
Vagrant.configure("2") do |config|
  config.vm.box = settings["box"]
  config.vm.hostname = settings["hostname"]
  config.vm.network "private_network", ip: settings["private_ip"]
  config.vm.network "forwarded_port", guest: 80, host: 8181

  config.vm.provider "virtualbox" do |vb|
    vb.memory = settings["memory"]
    vb.cpus = settings["cpus"] 
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  # Activation du chargement des variables d'environnement
  config.env.enable

  # Installation des plugins requis 
  required_plugins = %w( vagrant-vbguest vagrant-hostmanager )
  required_plugins.each do |plugin|
    unless Vagrant.has_plugin?(plugin)
      system("vagrant plugin install #{plugin}")
    end
  end

  # Scripts de provisionnement
  provisioning_scripts = %w(
    00-logging.sh
    00-variables.sh 
    01-dependencies.sh
    02-db.sh
    02-wordpress.sh
    03-woocommerce.sh
    03-word_woocommerce-check.sh
    04-api-keys.sh
    05-config.sh
    06-backup.sh
  )

  provisioning_scripts.each do |script|
    config.vm.provision "shell", 
      path: File.join("provision", script),
      env: settings.merge(settings['env'] || {}),
      privileged: false
  end

  config.vm.provision "shell", inline: "echo 'Environnement de développement prêt.'"
end
