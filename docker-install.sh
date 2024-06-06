#!/usr/bin/env bash


# Check Internet connectivity
CheckNetwork() {
	[[ ! $(nslookup "google.com" > /dev/null) ]] && echo -e "❌ No Internet connection! Check your network and retry.\n" && exit || :
}


# Configure the repository
[[ -f /usr/bin/apt ]] && PKG=apt || PKG=dnf
case $PKG in
    "apt")
	[[ ! -f /usr/bin/curl ]] && CheckNetwork && sudo apt update && sudo apt install curl -y || : 
	# Install docker on Ubuntu
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
	sudo docker run hello-world
	sudo usermod -aG docker $USER && sudo chmod a+rw /var/run/docker.sock
	# Install the NVIDIA Container Toolkit⁠
	if [[ $(lsmod | grep nvidia > /dev/null) ]]; then
		curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
		curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
		sudo apt update
		sudo apt install -y nvidia-container-toolkit
	else
		echo -e "NVIDIA driver is not found" && exit 1
	fi
	;;
    "dnf")
	# Install docker on RHEL9
	sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms
	sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
	sudo dnf install pass
	sudo dnf install gnome-shell-extension-appindicator
	sudo gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
	sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
	sudo dnf install ./*.rpm
	systemctl --user enable docker-desktop
	systemctl --user start docker-desktop
	# Install the NVIDIA Container Toolkit⁠
	if [[ $(lsmod | grep nvidia > /dev/null) ]]; then
		curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
		sudo dnf install -y nvidia-container-toolkit
	else
		echo -e "NVIDIA driver is not found" && exit 1
	fi
    ;;
esac

# Configure Docker to use Nvidia driver
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker


# Test GPU integration
# docker run --gpus all nvidia/cuda:11.5.2-base-ubuntu20.04 nvidia-smi