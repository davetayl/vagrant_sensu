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
  config.vm.define "agent" do |agent|
    agent.vm.box = "centos/8"
	agent.vm.provider "virtualbox" do |vb|
		vb.memory = 1024
		vb.cpus = 1
	end
	agent.vm.network "private_network", ip: "10.0.0.18", netmask:"255.255.255.0"
	agent.vm.provision "shell", path: "https://github.com/davetayl/Vagrant-General/raw/master/setup-centos8-nu.sh"
	agent.vm.provision "shell", path: "./provision-agent.sh"
  end

end