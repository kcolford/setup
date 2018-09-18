Vagrant.configure("2") do |config|
  config.vm.box = "archlinux/archlinux"
  config.vm.provision "shell", inline: <<-SHELL
  pacman -S ansible
  echo vagrant-test > /etc/hostname
  hostname -F /etc/hostname
  SHELL
end
