# Support de présentation du projet final

Ce support est rédigé au format markdown afin de pouvoir être versionné facilement.

Référentiels de la syntaxe markdown:

- <https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax>
- <https://www.markdownguide.org/basic-syntax/>
- <https://www.markdownguide.org/extended-syntax/>

## Partie 2

Le projet final sera versionné dans un repository **git** dont le dépôt principal sera hébergé ici:
<https://github.com/Romain-Revel/ajc-projet-final-2/>

L'infrastructure sera implémentée avec **vagrant** et avec le provider **Virtualbox**.
Le dossier infrastructure contiendra les fichiers et sous-dossiers nécessaires.

### Infrastructure

- Une VM jenkins
- Une VM docker pour le site web vitrine et pgadmin4
- Une VM docker pour l'application Odoo et sa base de données

### Correction d'un bug entre Virtualbox et Vagrant

Pour faire fonctionner le Vagrantfile sous Linux Mint, il faut ajouter un nom à l'interface réseau:
<https://www.vagrantup.com/docs/providers/virtualbox/networking>
