# Ollama + Open WebUI + Ngrok Docker Compose Setup
## Deploy LLM with a friendly UI and share it with remote hosts easily
####  Install Docker and NVIDIA container toolkit (if supported)
+ Run `bash docker-install.sh` (Skip this if Docker is already installed)
#
#### Install Ollama & Open WebUI & Ngrok
[Prerequisite] You need to register an account at https://ngrok.com and get your Authtoken
+ Power with CPU:
  + Run `export NGROK_AUTHTOKEN=<your_auth_token>`<br/>
  + Run `docker compose up -d`<br/>
  &nbsp;
+ Power with NVIDIA GPU (better performance):
  + Run `export NGROK_AUTHTOKEN=<your_auth_token>`<br/>
  + Run `docker compose -f docker-compose-NV-GPU up -d`
#
#### Last
+ Local login:
  + Open your browser and visit `localhost:8080`<br/>
  &nbsp;
+ Remote login (Internet):
  + Open your browser and visit `localhost:4040`.
  + Navigate to Ngrok -> Status -> Configuration -> Check the Tunnels URL (e.g., `https://*******.ngrok-free.app`)<br/>
&nbsp;
#
## Test environment
Ubuntu 22.04 LTS / RHEL 9.4
