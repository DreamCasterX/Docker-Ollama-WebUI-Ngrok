#!/usr/bin/env bash



# Fixed settings
red='\e[41m'
green='\e[32m'
yellow='\e[93m'
nc='\e[0m'



# Ensure the user is running the script as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${yellow}Please run as root to start the installation.${nc}"
    exit 1
fi

# Check Internet connectivity
CheckNetwork() {
	[[ $(nslookup "google.com" > /dev/null) ]] && echo -e "${red}No Internet connection! Check your network and retry.${nc}\n" && exit || :
}
CheckNetwork


# Identify Linux distro
[[ -f /usr/bin/apt ]] && PKG=apt || PKG=dnf
case $PKG in
    "apt"): 
	# Install docker on Ubuntu
	echo
	echo "╭───────────────────────────────────────╮"
	echo "│     Installing Docker on Ubuntu       │"
	echo "│                                       │"
	echo "╰───────────────────────────────────────╯"
	echo
	[[ ! -f /usr/bin/curl ]] && CheckNetwork && sudo apt update && sudo apt install curl -y || 
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
	echo -e "${green}Done!${nc}"
	# Install the NVIDIA Container Toolkit on Ubuntu
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
		# Configure Docker to use Nvidia driver
		sudo nvidia-ctk runtime configure --runtime=docker
		sudo systemctl restart docker
		# Test GPU integration
		sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
		echo -e "${green}Done!${nc}"
	else
		echo -e "NVIDIA driver is not installed. Stop configuring with GPU" && exit 1
	fi
	;;
    "dnf")
	# Install docker on RHEL9
	# Docker RPM package download url: https://download.docker.com/linux/rhel/9/x86_64/stable/Packages/
	echo
	echo "╭───────────────────────────────────────╮"
	echo "│     Installing Docker on RHEL9        │"
	echo "│                                       │"
	echo "╰───────────────────────────────────────╯"
	echo
    urls=(
      'https://download.docker.com/linux/rhel/9/x86_64/stable/Packages/containerd.io-1.7.25-3.1.el9.x86_64.rpm'
      'https://download.docker.com/linux/rhel/9/x86_64/stable/Packages/docker-buildx-plugin-0.21.1-1.el9.x86_64.rpm'
      'https://download.docker.com/linux/rhel/9/x86_64/stable/Packages/docker-ce-28.0.1-1.el9.x86_64.rpm'
      'https://download.docker.com/linux/rhel/9/x86_64/stable/Packages/docker-ce-cli-28.0.1-1.el9.x86_64.rpm'
      'https://download.docker.com/linux/rhel/9/x86_64/stable/Packages/docker-ce-rootless-extras-28.0.1-1.el9.x86_64.rpm'
      'https://download.docker.com/linux/rhel/9/x86_64/stable/Packages/docker-compose-plugin-2.33.1-1.el9.x86_64.rpm'
    )
    for url in "${urls[@]}"; do
      filename=$(basename "$url")
      if [ ! -f "$filename" ]; then
        wget "$url"
      fi
    done
    
	sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms
	sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
	sudo dnf install -y pass
	sudo dnf install -y gnome-shell-extension-appindicator
	sudo gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
	sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
	sudo dnf install -y ./*.rpm -y && sudo rm -f ./*.rpm 
	sudo systemctl enable docker
	sudo systemctl start docker
	echo -e "${green}Done!${nc}"
	# Install the NVIDIA Container Toolkit on RHEL9
	echo
	echo "╭───────────────────────────────────────╮"
	echo "│     Installing NVIDIA Toolkit         │"
	echo "│                                       │"
	echo "╰───────────────────────────────────────╯"
	echo
	if [[ ! $(lsmod | grep nvidia > /dev/null) ]]; then
		curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
		sudo dnf install -y nvidia-container-toolkit
		# Configure Docker to use Nvidia driver
		sudo nvidia-ctk runtime configure --runtime=docker
		sudo systemctl restart docker
		# Test GPU integration
		sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
		echo -e "${green}Done!${nc}"
	else
		echo -e "NVIDIA driver is not installed. Stop configuring with GPU" && exit 1
	fi
    ;;
esac







