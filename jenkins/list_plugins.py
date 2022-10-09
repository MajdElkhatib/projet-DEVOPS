import os
import requests

JENKINS_USERNAME = os.getenv('JENKINS_USERNAME')
JENKINS_PASSWORD = os.getenv('JENKINS_PASSWORD')
JENKINS_IP = os.getenv('JENKINS_IP')
JENKINS_PORT = os.getenv('JENKINS_PORT')

response = requests.get(f"http://{JENKINS_USERNAME}:{JENKINS_PASSWORD}@{JENKINS_IP}:{JENKINS_PORT}/pluginManager/api/json?depth=1&?xpath=/*/*shortName|/*/*/version")
data = response.json()['plugins']
plugins = []

for plugin in data:
    #print ("%s:%s" % (plugin["shortName"], plugin["version"]))
    plugins.append(f"{plugin['shortName']}:{plugin['version']}")

plugins.sort()

for plugin in plugins:
    print(plugin)
