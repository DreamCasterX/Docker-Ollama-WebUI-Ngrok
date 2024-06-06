#!/usr/bin/env bash


# Check Internet connectivity
CheckNetwork() {
	[[ $(nslookup "google.com" > /dev/null) ]] && echo -e "❌ No Internet connection! Check your network and retry.\n" && exit || :
}


# Configure the repository
[[ -f /usr/bin/apt ]] && PKG=apt || PKG=dnf
case $PKG in
    "apt")
	[[ ! -f /usr/bin/curl ]] && CheckNetwork && sudo apt update && sudo apt install curl -y || : 
	# Install docker on Ubuntu
	echo
	echo "╭───────────────────────────────────────╮"
	echo "│     Installing Docker on Ubuntu       │"
	echo "│                                       │"
	echo "╰───────────────────────────────────────╯"
	echo
	for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
	sudo apt update
	sudo apt install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt update
	sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo usermod -aG docker $USER && sudo chmod a+rw /var/run/docker.sock
	echo -e "\e[32mDone!\e[0m"
	# Install the NVIDIA Container Toolkit⁠
	echo
	echo "╭───────────────────────────────────────╮"
	echo "│     Installing NVIDIA Toolkit         │"
	echo "│                                       │"
	echo "╰───────────────────────────────────────╯"
	echo
	if [[ ! $(lsmod | grep nvidia > /dev/null) ]]; then
		curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
		curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
		sudo apt update
		sudo apt install -y nvidia-container-toolkit
		echo -e "\e[32mDone!\e[0m"
	else
		echo -e "NVIDIA driver is not found" && exit 1
	fi
	;;
    "dnf")
	# Install docker on RHEL9
	# RPM package download url: https://download.docker.com/linux/rhel/9/x86_64/stable/Packages/
	echo
	echo "╭───────────────────────────────────────╮"
	echo "│     Installing Docker on RHEL9        │"
	echo "│                                       │"
	echo "╰───────────────────────────────────────╯"
	echo
	wget 'https://download.docker.com/linux/rhel/9/x86_64/stable/Packages/containerd.io-1.6.33-3.1.el9.x86_64.rpm'
	wget 'https://download.docker.com/linux/rhel/9/x86_64/stable/Packages/docker-buildx-plugin-0.14.1-1.el9.x86_64.rpm'
	wget 'https://download.docker.com/linux/rhel/9/x86_64/stable/Packages/docker-ce-26.1.4-1.el9.x86_64.rpm'
	wget 'https://download.docker.com/linux/rhel/9/x86_64/stable/Packages/docker-ce-cli-26.1.4-1.el9.x86_64.rpm'
	wget 'https://download.docker.com/linux/rhel/9/x86_64/stable/Packages/docker-ce-rootless-extras-26.1.4-1.el9.x86_64.rpm'
	wget 'https://download.docker.com/linux/rhel/9/x86_64/stable/Packages/docker-compose-plugin-2.27.1-1.el9.x86_64.rpm'
	sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms
	sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
	sudo dnf install pass
	sudo dnf install gnome-shell-extension-appindicator
	sudo gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
	sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
	sudo dnf install ./*.rpm  
	systemctl --user enable docker-desktop
	systemctl --user start docker-desktop
	echo -e "\e[32mDone!\e[0m"
	# Install the NVIDIA Container Toolkit⁠
	echo
	echo "╭───────────────────────────────────────╮"
	echo "│     Installing NVIDIA Toolkit         │"
	echo "│                                       │"
	echo "╰───────────────────────────────────────╯"
	echo
	if [[ ! $(lsmod | grep nvidia > /dev/null) ]]; then
		curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
		sudo dnf install -y nvidia-container-toolkit
		echo -e "\e[32mDone!\e[0m"
	else
		echo -e "NVIDIA driver is not found" && exit 1
	fi
    ;;
esac

# Configure Docker to use Nvidia driver
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker


# Test GPU integration
docker run --gpus all nvidia/cuda:11.5.2-base-ubuntu20.04 nvidia-smi


