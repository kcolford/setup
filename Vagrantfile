Vagrant.configure("2") do |config|
  config.vm.box = "archlinux/archlinux"
  config.vm.provision "shell", inline: <<-SHELL
  pacman -Syu --noconfirm ansible
  echo test ansible_connection=local > /etc/ansible/hosts
  SHELL
end
