Vagrant.configure("2") do |config|
  config.vm.define "sensuapp" do |sensuapp|
    sensuapp.vm.box = "centos/8"
	sensuapp.vm.provider "virtualbox" do |vb|
		vb.memory = 2048
		vb.cpus = 2
	end
	sensuapp.vm.network "private_network", ip: "10.0.0.17", netmask:"255.255.255.0"
	sensuapp.vm.network "forwarded_port", guest: 3000, host: 80
	sensuapp.vm.provision "shell", path: "https://github.com/davetayl/Vagrant-General/raw/master/setup-centos8-nu.sh"
	sensuapp.vm.provision "shell", path: "./provision-sensuapp.sh"
  end
  config.vm.define "influxdb" do |influxdb|
    influxdb.vm.box = "centos/8"
	influxdb.vm.provider "virtualbox" do |vb|
		vb.memory = 1024
		vb.cpus = 1
	end
	influxdb.vm.network "private_network", ip: "10.0.0.18", netmask:"255.255.255.0"
	influxdb.vm.provision "shell", path: "https://github.com/davetayl/Vagrant-General/raw/master/setup-centos8-nu.sh"
	influxdb.vm.provision "shell", path: "./provision-influxdb.sh"
  end
  config.vm.define "grafana" do |grafana|
    grafana.vm.box = "centos/8"
	grafana.vm.provider "virtualbox" do |vb|
		vb.memory = 2048
		vb.cpus = 2
	end
	grafana.vm.network "private_network", ip: "10.0.0.19", netmask:"255.255.255.0"
	grafana.vm.provision "shell", path: "https://github.com/davetayl/Vagrant-General/raw/master/setup-centos8-nu.sh"
	grafana.vm.provision "shell", path: "./provision-grafana.sh"
  end
  config.vm.define "agent1" do |agent1|
    agent1.vm.box = "centos/8"
	agent1.vm.provider "virtualbox" do |vb|
		vb.memory = 1024
		vb.cpus = 1
	end
	agent1.vm.network "private_network", ip: "10.0.0.33", netmask:"255.255.255.0"
	agent1.vm.provision "shell", path: "https://github.com/davetayl/Vagrant-General/raw/master/setup-centos8-nu.sh"
	agent1.vm.provision "shell", path: "./provision-agent1.sh"
  end
  config.vm.define "agent2" do |agent2|
    agent2.vm.box = "centos/8"
	agent2.vm.provider "virtualbox" do |vb|
		vb.memory = 1024
		vb.cpus = 1
	end
	agent2.vm.network "private_network", ip: "10.0.0.34", netmask:"255.255.255.0"
	agent2.vm.provision "shell", path: "https://github.com/davetayl/Vagrant-General/raw/master/setup-centos8-nu.sh"
	agent2.vm.provision "shell", path: "./provision-agent2.sh"
  end

end