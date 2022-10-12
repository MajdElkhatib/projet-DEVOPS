---
marp: true
theme: uncover
header: 'PROJET FINAL DEVOPS'
footer: 'Groupe 3'
paginate: true
---


## Partie 2

---
### Mise en place d’un pipeline CI/CD

---

### Ansible

---

### Création des Rôles Ansible

Déployer des conteneurs docker avec 2 rôles  : 

- odoo_role : lance 2 conteneurs celui de odoo et celui de la base de donnée postgres
- pgadmin_role :  lance le site vitrine ic-webapp et un conteneur pgadmin pour visualiser la base de donnée postgres de odoo

NB : Toutes les données sont variabilisées donc pourront être surchargée par ansible


---

### Rôle Odoo
Déploie 2 conteneurs avec le template docker-compose  :
- Conteneur odoo
- Conteneur postgres

---

templates/docker-compose.yml.j2

```yaml
# Template docker-compose for odoo
version: '3.3'
services:

    {{ SERVICE_POSTGRES }}:
        environment:
            - 'POSTGRES_USER={{ DB_USER }}'
            - 'POSTGRES_PASSWORD={{ DB_PASS }}'
            - 'POSTGRES_DB={{ DB_NAME }}'
        networks:
            - {{ NETWORK_NAME }}
        volumes:
            - 'pgdata:{{ MOUNT_POINT_POSTGRES }}'
        container_name: {{ CONTAINER_NAME_POSTGRES }}
        image: 'postgres:13'
        ports:
            - '{{ POSTGRES_PORT }}:5432'
    {{ SERVICE_ODOO }}:
        depends_on:
            - {{ SERVICE_POSTGRES }}
        ports:
            - '{{ ODOO_PORT }}:8069'
        container_name: {{ CONTAINER_NAME_ODOO }}
        networks:
            - {{ NETWORK_NAME }}
        volumes:
            - 'odoo-web-data:/var/lib/odoo'
        environment:
            - 'USER={{ DB_USER }}'
            - 'PASSWORD={{ DB_PASS }}'
            - 'HOST={{ DB_NAME }}'
        image: odoo:13

volumes:
    odoo-web-data:
    pgdata:
networks:
    {{ NETWORK_NAME }}:
      driver: bridge
```

---
defaults/main.yml

``` yaml
# defaults file for odoo_role

DB_USER: "odoo"
DB_PASS: "odoo"
DB_NAME: "postgres"
POSTGRES_PORT: "5432"
ODOO_PORT: "8081"
IC_PORT: "80"
HOST_IP: "192.168.99.20"
SERVICE_POSTGRES: "postgres"
SERVICE_ODOO: "odoo"
NETWORK_NAME: "ic_network"
CONTAINER_NAME_POSTGRES: "postgres"
CONTAINER_NAME_ODOO: "odoo"
MOUNT_POINT_POSTGRES: "/var/lib/postgresql/data"
```
---

tasks/main.yml

```yaml
# tasks file for odoo_role

- name: creation un repertoire files
  file:
    path: "/home/{{ ansible_user }}/files/"
    recurse: yes
    state: directory
- name: generer un fichier docker-compose
  template:
    src: "docker-compose.yml.j2"
    dest: "/home/{{ ansible_user }}/files/docker-compose.yml"
- name: "Deploiement"
  command: "docker-compose up -d"
  args:
    chdir: "/home/{{ ansible_user }}/files"
```

---

### Rôle PgAdmin

---

Déploie deux conteneurs via les templates docker-compose et servers :

- pgadmin
- ic-webapp

----

templates/docker-compose.yml.j2

```yaml
# Template docker-compose for pgadmin and ic-webapp
version: '3.3'
services:
    {{ SERVICE_PGADMIN }}:
        container_name: {{ CONTAINER_NAME_PGADMIN }}
        image: dpage/pgadmin4
        networks:
            - {{ NETWORK_NAME }}
        environment:
            - 'PGADMIN_DEFAULT_EMAIL={{ PGADMIN_EMAIL }}'
            - 'PGADMIN_DEFAULT_PASSWORD={{ PGADMIN_PASS }}'
        ports:
            - "{{ PGADMIN_PORT }}:80"
        volumes:
            - /home/{{ ansible_user }}/files/servers.json:/pgadmin4/servers.json
            - 'pgadmin_data:/var/lib/pgadmin'

    {{ SERVICE_ICWEBAPP }}:
        container_name: {{ CONTAINER_NAME_ICWEBAPP }}
        ports:
            - "{{ IC_PORT }}:8080"
        environment:
            - "ODOO_URL=http://{{ POSTGRES_IP }}:{{ ODOO_PORT }}/"
            - "PGADMIN_URL=http://{{ HOST_IP }}:{{ PGADMIN_PORT }}/"
        image: '{{ IMAGE_NAME }}:{{ IMAGE_TAG }}'
        networks:
            - {{ NETWORK_NAME }}

volumes:
    pgadmin_data:
networks:
    {{ NETWORK_NAME }}:
      driver: bridge
 ```     

---

servers.json.j2

```json

{
    "Servers": {
        "1": {
            "Name": "{{ DB_NAME }}",
            "Group": "docker_postgres_group_1",
            "Port": {{ POSTGRES_PORT }},
            "Username": "{{ DB_USER }}",
            "Host": "{{ POSTGRES_IP }}",
            "SSLMode": "prefer",
            "MaintenanceDB": "{{ DB_NAME }}"
        }
    }
}
```

---

defaults/main.yml

```yaml
# defaults file for pgadmin_role
PGADMIN_EMAIL: "user@domain.com"
PGADMIN_PASS: "odoo_pgadmin_password"
PGADMIN_PORT: "8082"
DB_USER: "odoo"
DB_PASS: "odoo"
DB_NAME: "postgres"
POSTGRES_PORT: "5432"
ODOO_PORT: "8081"
IC_PORT: "80"
HOST_IP: "192.168.99.21"
POSTGRES_IP: "192.168.99.20"
IMAGE_NAME: "sh0t1m3/ic-webapp"
IMAGE_TAG: "1.0"
SERVICE_PGADMIN: "pgadmin"
SERVICE_ICWEBAPP: "ic-webapp"
NETWORK_NAME: "ic_network"
CONTAINER_NAME_PGADMIN: "pgadmin"
CONTAINER_NAME_ICWEBAPP: "ic-webapp"
```
---

tasks/main.yml

```yaml
# tasks file for pgadmin_role

- name: creation repertoire files
  file:
    path: "/home/{{ ansible_user }}/files/"
    recurse: yes
    state: directory
- name: générer docker-compose
  template:
    src: "docker-compose.yml.j2"
    dest: "/home/{{ ansible_user }}/files/docker-compose.yml"

- name: pgadmin config file servers
  template:
    src: "servers.json.j2"
    dest: "/home/{{ ansible_user }}/files/servers.json"

- name: "Deploiement"
  command: "docker-compose up -d"
  args:
    chdir: "/home/{{ ansible_user }}/files"
```
---

### Le Playbook Ansible

---
Un playbook Ansible est un modèle de tâches d'automatisation. Les playbooks Ansible sont exécutés sur un ensemble, un groupe ou une classification d'hôtes, qui forment ensemble un inventaire.

Source: https://www.redhat.com/fr/topics/automation/what-is-an-ansible-playbook
---
play.yml


```yaml
# Notre playbook 
- name: "installation de odoo"
  hosts: prod-odoo
  roles:
    - role: odoo_role
- name: "Installation de pgadmin"
  hosts: prod-pgadmin
  roles:
    - role: pgadmin_role
```    

---

prods.yml

```yaml
# L'inventaire
all:
  children:
    prod-odoo:
      hosts:
        docker-odoo:
    prod-pgadmin:
      hosts:
        docker-pgadmin-icwebapp:
```

---
La structure de notre répertoire Ansible

```yaml
├── group_vars
│   ├── prod-odoo.yml
│   └── prod-pgadmin.yml
├── host_vars
│   ├── docker-odoo.yml
│   └── docker-pgadmin-icwebapp.yml
├── play.yml
├── prods.yml
└── roles
    ├── odoo_role
    │   ├── defaults
    │   │   └── main.yml
    │   ├── handlers
    │   │   └── main.yml
    │   ├── meta
    │   │   └── main.yml
    │   ├── README.md
    │   ├── tasks
    │   │   └── main.yml
    │   ├── templates
    │   │   └── docker-compose.yml.j2
    │   ├── tests
    │   │   ├── inventory
    │   │   └── test.yml
    │   └── vars
    │       └── main.yml
    └── pgadmin_role
        ├── defaults
        │   └── main.yml
        ├── handlers
        │   └── main.yml
        ├── meta
        │   └── main.yml
        ├── README.md
        ├── tasks
        │   └── main.yml
        ├── templates
        │   ├── docker-compose.yml.j2
        │   └── servers.json.j2
        ├── tests
        │   ├── inventory
        │   └── test.yml
        └── vars
            └── main.yml
```
---

## Conclusion