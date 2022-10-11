#!/bin/bash

FILE_NAME="ngrok-v3-stable-linux-amd64.tgz";

if [[ ! -f "/usr/local/bin/ngrok" ]]; then
    # Téléchargement
    # https://ngrok.com/download
    if [[ ! -f "${FILE_NAME}" ]]; then
        wget "https://bin.equinox.io/c/bNyj1mQVY4c/${FILE_NAME}";
    fi

    # Décompression et installation
    sudo tar xvzf "${FILE_NAME}" -C /usr/local/bin;
fi

sleep 3

# Enregistrement
ngrok config add-authtoken $(cat token.txt);

# Lancement
nohup ngrok http 8080 &

# Récupération de l'URL
curl "http://localhost:4040/api/tunnels";
