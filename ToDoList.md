# Ansible

## Priorité haute

	* Modifier les roles Ansible
	** Variabiliser les noms des services et des noms de conteneurs // Fait !

	* Spécifique au role pgadmin
	** Variabiliser le TAG pour l'image ic-webapp // Fait !

## Priorité normale

	* Modifier la partie Ansible pour gérer la partie vault (On va faire autrement)

	* Voir ce qu'il faut modifier dans les rôles pour faire un redéploiement // Fait !

## Priorite basse

	* Rajouter dans les docker-compose une partie healthcheck des conteneurs 

## Priorite basse

	* Déployer docker et docker-compose sur les vms via ansible

# Jenkins

## Priorité Haute

	* Build une nouvelle image lors du changement du fichier release.txt // fait
	* Tester cette nouvelle image // fait
	* Push de l'image sur le registry dockerhub // fait

	* Lancer le playbook avec un redéploiment du docker-compose contenant le conteneur ic-webapp  avec des extras vars // Fait !!

	* Lancer le playbook play.yml avec des extra-vars //Fait !!

# Conteneur pgadmin

## Priorité normale

	* Regler le problème de la configuration de serveur (serveurs.json) // Pas résolu encore
