#!/bin/bash

# Didacticiel intéressant:
# https://medium.com/oracledevs/expose-docker-container-services-on-the-internet-using-the-ngrok-docker-image-3f1ea0f9c47a

# INVALIDE
docker run -it -e NGROK_AUTHTOKEN=2EhvD3w8XxWzoy2IkQICychVNag_2iw6xPyAsJiHNLSUBCdt7 ngrok/ngrok http 8080

# INVALIDE
docker run -dit --name ngrok -e NGROK_AUTHTOKEN=2EhvD3w8XxWzoy2IkQICychVNag_2iw6xPyAsJiHNLSUBCdt7 --net jenkins_default ngrok/ngrok http 8080

# INVALIDE
docker run -dit -p 4040:4040 --name ngrok -e NGROK_AUTHTOKEN=2EhvD3w8XxWzoy2IkQICychVNag_2iw6xPyAsJiHNLSUBCdt7 --net jenkins_default ngrok/ngrok http 8080

# INVALIDE
docker run -dit -p 4040:4040 --name ngrok -e NGROK_AUTHTOKEN=2EhvD3w8XxWzoy2IkQICychVNag_2iw6xPyAsJiHNLSUBCdt7 --net jenkins_default ngrok/ngrok http 8080

# INVALIDE
docker run -dit -p 4040:4040 --name ngrok -e NGROK_AUTHTOKEN=2EhvD3w8XxWzoy2IkQICychVNag_2iw6xPyAsJiHNLSUBCdt7 --net jenkins_default ngrok/ngrok http 127.0.0.1:8080

# Commande fonctionnelle mais DOIT rester lancée...
docker run -it -p 4040:4040 --name ngrok -e NGROK_AUTHTOKEN=2EhvD3w8XxWzoy2IkQICychVNag_2iw6xPyAsJiHNLSUBCdt7 --net host ngrok/ngrok http 127.0.0.1:8080

docker exec -it ngrok /bin/bash

# Récupération de l'URL
curl $(docker port ngrok 4040)/api/tunnels

# Nettoyage
docker stop ngrok && docker rm ngrok
