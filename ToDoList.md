# Ansible
## Priorité haute
	* Modifier les roles Ansible
	* Variabiliser les noms des services et des noms de conteneurs

	### Spécifique au role pgadmin
	* Variabiliser le TAG pour l'image ic-webapp

## Priorité haute
	* Modifier la partie Ansible pour gérer la partie vault

	* Voir ce qu'il faut modifier dans les rôles pour faire un redéploiement

## Priorite basse
	* Rajouter dans les docker-compose une partie healthcheck des conteneurs

## Priorite basse
	* Déployer docker et docker-compose sur les vms via ansible

#Jenkins
# Priorité Haute
	* Build une nouvelle image lors du changement du fichier release.txt
	* Tester cette nouvelle image
	* Push de l'image sur le registry dockerhub
	* Lancer le playbook avec un redéploiment du docker-compose contenant le conteneur ic-webapp  avec des extras vars

#Jenkins
# Priorité Haute
	* Lancer le playbook play.yml avec des extras vars

# Conteneur pgadmin
# Priorité normale
	* Regler le problème de la configuration de serveur (serveurs.json)
