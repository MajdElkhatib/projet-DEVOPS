# Jenkins

## Récupérer le mot de passe aléatoire

```shell
cat /var/lib/docker/volumes/jenkins_jenkins_home/_data/secrets/initialAdminPassword
```

## Récupérer la liste des plugins

<https://stackoverflow.com/questions/9815273/how-to-get-a-list-of-installed-jenkins-plugins-with-name-and-version-pair>
<https://gist.github.com/noqcks/d2f2156c7ef8955619d45d1fe6daeaa9>

```groovy
Jenkins.instance.pluginManager.plugins.each{
  plugin ->
    println ("${plugin.getDisplayName()} (${plugin.getShortName()}): ${plugin.getVersion()}")
}
```

```groovy
def pluginList = new ArrayList(Jenkins.instance.pluginManager.plugins)
pluginList.sort { it.getShortName() }.each{
  plugin ->
    println ("${plugin.getDisplayName()} (${plugin.getShortName()}): ${plugin.getVersion()}")
}
```

Voir le script

https://python-jenkins.readthedocs.io/en/latest/examples.html#example-5-working-with-jenkins-plugins

https://stackoverflow.com/questions/50134359/jenkins-python-api-install-plugin


## Pour télécharger une liste de plugins Jenkins en python

<https://python-jenkins.readthedocs.io/en/latest/examples.html#example-1-get-version-of-jenkins>

<https://gist.github.com/anadimisra/c68171489b7b77f4c590047193e5496a>

## Préconfigurer les plugins avec Docker

<https://github.com/jenkinsci/docker#preinstalling-plugins>

## Installer des plugins avec Python

<https://stackoverflow.com/questions/50134359/jenkins-python-api-install-plugin>

## Gérer Jenkins avec curl

<https://stackoverflow.com/questions/9765728/how-to-install-plugins-in-jenkins-with-the-help-of-jenkins-remote-access-api>

https://gist.github.com/micw/e80d739c6099078ce0f3

https://github.com/cloudogu/gitops-playground/blob/d41094a7927f91cb05aaa40b35b5410719ed1e8b/scripts/jenkins/init-jenkins.sh#L98-L104

https://github.com/cloudogu/gitops-playground/blob/d41094a7927f91cb05aaa40b35b5410719ed1e8b/scripts/jenkins/jenkins-REST-client.sh

https://medium.com/@muku.hbti/export-import-jenkins-job-and-their-plugins-53cafa5869fa

## Plugins à tester

https://www.jenkins.io/doc/book/managing/casc/
https://plugins.jenkins.io/configuration-as-code/

https://plugins.jenkins.io/saferestart/

## Sauvegarder / versionner la configuration de Jenkins

https://jenkins-le-guide-complet.github.io/html/sect-maint-backups.html
https://www.toolsqa.com/jenkins/jenkins-backup-plugin

https://github.com/sue445/jenkins-backup-script
https://gist.github.com/cenkalti/5089392

https://www.baeldung.com/ops/jenkins-export-import-jobs
