---
marp: true
theme: uncover
header: 'PROJET FINAL DEVOPS'
footer: 'Groupe 3'
paginate: true
---

# PROJET FINAL DEVOPS

**Groupe 3**
- Majd EL KHATIB (OP CONSULTING)
- Christophe GARCIA (SPIE ICS Toulouse)
- Romain REVEL (SPIE ICS Grenoble)

---

## Table des matières

---

## Introduction

---

### Contexte

Formation
- chez AJC Formation
- du 25/07/2022 au 13/10/2022
- sur le **DevOps**

Ce document est le rendu du projet final

---

### Rappel du sujet

La société IC GROUP souhaite mettre sur
pied un site **web vitrine** devant permettre d’accéder à ses 02 applications phares: **Odoo** et **pgAdmin**

---

### Analyse du sujet

1)
  * Conteneurisation de la web app python (Flask) avec **Docker**
  * Déploiement des 3 produits sur un cluster **Kubernetes**

2)
  * Mise en place d'un pipeline CI/CD à l'aide de **Jenkins** et de **Ansible**

---

### Méthodologie

2 possibilités:

- Coopération: chacun traite un point particulier de son côté puis mise en commun
- Collaboration: tout le monde se concentre sur le même point particulier

Source: https://www.votre-it-facile.fr/travail-collaboratif-et-travail-cooperatif-difference/

---

### Choix des outils

- Communication (voix / texte / partage d'écran)
  - Discord

- Versionnement
  - Git
  - Github
  - Gitkraken: client Git beau et ergonomique

- Infrastructure
  - Virtualbox
  - Vagrant

---

## Partie 1

---

### Infrastructure

- Github
  https://github.com/Romain-Revel/ajc-projet-final
- Docker
  https://hub.docker.com/repository/docker/sh0t1m3/ic-webapp
- Kubernetes / Minikube

- Postes: **Windows 10** et **Linux Mint** -> complications

---

### Vagrant

```ruby
# Version initiale fonctionnant uniquement sous Windows
Vagrant.configure("2") do |config|
  config.vm.define "docker" do |docker|
    docker.vm.box = "geerlingguy/centos7"
    docker.vm.network "private_network",  type: "static", ip: "192.168.99.11"
    docker.vm.hostname = "docker"
    docker.vm.provider "virtualbox" do |v|
      v.name = "docker"
      v.memory = 1024
      v.cpus = 2
    end
    docker.vm.provision :shell do |shell|
      shell.path = "install_docker.sh"
      shell.env = { 'ENABLE_ZSH' => ENV['ENABLE_ZSH'] }
    end
  end
end
```

---

```ruby
# Module pour gérer l'OS hôte
module OS
        def OS.windows?
                (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
        end
        def OS.mac?
                (/darwin/ =~ RUBY_PLATFORM) != nil
        end
        def OS.unix?
                !OS.windows?
        end
        def OS.linux?
                OS.unix? and not OS.mac?
        end
end
```

---

```ruby
    # Ajout
    docker.vm.box = "geerlingguy/centos7"
    if OS.linux?
        # Sous linux, il FAUT préciser le nom du réseau hôte
        # https://www.vagrantup.com/docs/providers/virtualbox/networking
        # Dans Virtualbox > Fichier > Gestionnaire de réseau hôte (CTRL + H):
        # - Vérifier la présence de vboxnet0, sinon le créer
        # - Vérifier l'adresse IPv4 et le masque, sinon les modifier (à faire 2 fois pour être pris en compte)
        #
        # Vérifier avec "ip -a" le nom, l'IP et le masque
        docker.vm.network "private_network",  type: "static", ip: "192.168.99.11", name: "vboxnet0"
    elsif OS.windows?
        docker.vm.network "private_network",  type: "static", ip: "192.168.99.11"
    else
        puts 'OS not managed'
    end
    # ...
```

---

### Conteneurisation de la web app

https://github.com/sadofrazer/ic-webapp.git

Comment l'intégrer dans notre repo git ?
- Copier-coller -> le plus simple
- Git submodules -> trop compliqué et risqué
- Git subtrees -> pas le temps

---

```docker
# Dockerfile ic-webapp
FROM alpine:3.6
ENV ODOO_URL=""
ENV PGADMIN_URL=""
# Install python and pip
RUN apk add --no-cache --update python3 py3-pip bash && \
        # Install dependencies
        pip3 install Flask && \
        # Add a Group and user icwebapp
        addgroup -S icwebapp && \
        adduser -S icwebapp -G icwebapp
# Add our code
COPY --chown=icwebapp:icwebapp ic-webapp /opt/ic-webapp/
USER icwebapp
WORKDIR /opt/ic-webapp
EXPOSE 8080
CMD [ "python3", "app.py" ]
```

---

```bash
#!/bin/bash
# Script avec les commandes séquentielles
image="ic-webapp"
name="test-ic-webapp"
port="8080"
docker stop ${name} && docker rm ${name}
# Build soit en taggant directement soit en retaggant:
# docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
docker build -t sh0t1m3/${image}:1.0 .
docker run -d -p ${port}:${port} \
  -e ODOO_URL='https://www.odoo.com/' \
  -e PGADMIN_URL='https://www.pgadmin.org/' \
  --name=${name} sh0t1m3/${image}:1.0

sleep 3

curl http://localhost:${port}
```

---

![bg w:100%](./images/webapp.png)

---

```bash
#!/bin/bash
# Script de publication et de nettoyage
image="ic-webapp"
name="test-ic-webapp"

docker stop ${name}
docker rm ${name}

docker login
docker push sh0t1m3/${image}:1.0

# docker rmi ${image}
# docker rm $(docker ps -aq)
# docker rmi $(docker images -aq)
```

---

![bg w:100%](./images/docker-hub-1.0.png)

---

### Déploiement avec Kubernetes
- Installation de longhorn (avec helm)
- Création des manifests
- Application des manifests
---

#### Helm

Kubernetes package manager : https://helm.sh/

```bash
#!/bin/bash
# Helm installation
HELM_PATH="$(which helm)"

if [ "${HELM_PATH}" == "" ]; then
        # Get HELM
        curl https://get.helm.sh/helm-v3.10.0-linux-amd64.tar.gz -o helm-v3.10.0-linux-amd64.tar.gz
        tar xfz helm-v3.10.0-linux-amd64.tar.gz
        sudo mv linux-amd64/helm /usr/local/bin && chmod +x /usr/local/bin/helm
        rm -Rf tar xfz helm-v3.10.0-linux-amd64.tar.gz linux-amd64/
        HELM_PATH=/usr/local/bin/helm
fi
```


---
#### Longhorn
Cloud native distributed block storage for Kubernetes

```bash
# Longhorn installation with helm
su vagrant -c "${HELM_PATH} repo add longhorn https://charts.longhorn.io"
if [ $? -ne 0 ]; then
        echo "Impossible d'ajouter le repo à helm"
        exit 1
fi

su vagrant -c "${HELM_PATH} repo update"

su vagrant -c "${HELM_PATH} install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace"
if [ $? -ne 0 ]; then
        echo "Impossible d'installer longhorn"
        exit 1
fi
```

---

#### Architecture du namespace

![h: 80% w:80%](./images/schema-kubernetes.png)


---

#### Les manifests

- Namespace
  ```bash
  kubectl create ns icgroup
  ```

- Secrets
  La génération des secrets doit etre manuelle pour éviter un stockage du mot de passe.

  ```bash
  kubectl create secret generic  odoo-pgsql-password --from-literal=odoo=YOUR_PASSWORD -n icgroup
  ```

---

- PVCs (pour les applications où cela est nécessaire)
  - Storageclass Longhorn

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-postgres-claim
  namespace: icgroup
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: "longhorn"
  resources:
    requests:
      storage: 2Gi
```
---

<!--
_header: 'Schéma des PVC'
 -->

![bg h:80% w:80%](./images/k8s-graph-pvc.svg)

---

- Deploiements
  - Réplicaset
  - Label : env=prod et app=...
  - security-context

---

- Services
  - ClusterIP
  - NodePort
  - Loadbalancing(round-robin)


---

## Partie 2

---

## Conclusion
