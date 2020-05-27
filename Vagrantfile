Vagrant.configure("2") do |config|
  config.vm.define "sensuapp" do |sensuapp|
    config.vm.box = "centos/8"
    config.vm.box_version = "1905.1"
	sensuapp.vm.network "forwarded_port", guest: 3000, host: 80
	sensuapp.vm.provision "shell", path: "./provision-sensuapp.sh"
  end
end