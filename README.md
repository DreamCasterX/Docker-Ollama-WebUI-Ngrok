# Ollama + Open WebUI + Ngrok Docker Compose Setup
## Deploy LLM with a friendly UI and share it with remote hosts easily
####  Install Docker and NVIDIA container toolkit (if supported). You can skip this if docker is already installed
  ```bash
  bash install_docker.sh
  ```

#
#### Install Ollama & Open WebUI & Ngrok
You need to register an account at https://ngrok.com and copy your auth token from there
+ Power with CPU:
  ```bash
  export NGROK_AUTHTOKEN=<paste_your_auth_token_here>
  docker compose up -d
  ```
  &nbsp;
+ Power with NVIDIA GPU:
   ```bash
  export NGROK_AUTHTOKEN=<paste_your_auth_token_here>
  docker compose -f docker-compose-NV-GPU.yml up -d
  ``` 
#
#### Last
+ Local login:
  + Open your browser and visit `localhost:8080`<br/>
  &nbsp;
+ Remote login (Internet):
  + Open your browser and visit `localhost:4040`.
  + Navigate to Ngrok -> Status -> Configuration -> Check the Tunnels URL (e.g., `https://*******.ngrok-free.app`)<br/>
  &nbsp;
+ Stop all the docker containers
  ```bash
  docker compose down
  ```
&nbsp;
## Test environment
Ubuntu 22.04 LTS / RHEL 9.4
