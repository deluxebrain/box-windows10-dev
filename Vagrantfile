# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "windows_10_basebox"

  config.vm.communicator = "winrm"
  config.winrm.port = 5985
  config.winrm.guest_port = 5985
  config.winrm.transport = :plaintext
  config.winrm.basic_auth_only = true
  config.winrm.username = "vagrant"
  config.winrm.password = "vagrant"

  config.vm.guest = :windows
  config.windows.halt_timeout = 15

  config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
  config.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
  config.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
  config.vm.network :forwarded_port, guest: 5986, host: 5986, id: "winrm", auto_correct: true

  config.vm.synced_folder ".",
    "/vagrant"

  if Vagrant.has_plugin?("vagrant-timezone")
    # match host timezone
    # can use explicit values from TZ database, e.g.
    # config.timezone.value = "Europe/London"
    config.timezone.value = :host
  end

  config.vm.provider :virtualbox do |v, override|
    v.gui = false
    v.customize ["modifyvm", :id, "--memory", 2048]
    v.customize ["modifyvm", :id, "--cpus", 2]
    v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
  end

  config.vm.provider :vmware_fusion do |v, override|
    v.gui = true
    v.vmx["memsize"] = "2048"
    v.vmx["numvcpus"] = "2"
    v.vmx["ethernet0.virtualDev"] = "vmxnet3"
    v.vmx["RemoteDisplay.vnc.enabled"] = "false"
    v.vmx["RemoteDisplay.vnc.port"] = "5900"
    v.vmx["scsi0.virtualDev"] = "lsisas1068"
  end

  # Copy up the boxstarter configuration file
  config.vm.provision "file",
    source: "./scripts/Configure-DevBox.ps1",
    destination: "c:\\tools\\Configure-DevBox.ps1"

  # Install boxstarter and provision the box using the configuration file
  config.vm.provision "shell",
    path: "./scripts/Install-Boxstarter.ps1"
end

