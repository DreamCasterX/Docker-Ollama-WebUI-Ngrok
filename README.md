# Deploy Local LLM 

## Ollama Docker Compose Setup with Open WebUI
 1. Put all the scipts into a single folder and `cd` to it
 #
 2. Run `bash docker-install.sh` to install Docker and NVIDIA container toolkit (if supported)
 #
 3. Run `dockerdocker compose up -d` to power with CPU
    #### Alternatively, run `docker compose -f docker-compose-NV-GPU up -d` to power with NVIDIA GPU (better performance)
 #
 4. Visit `localhost:8080` from your browser to open WebUI

