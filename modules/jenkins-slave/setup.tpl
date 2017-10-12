#!/bin/bash

export PASS=$(sudo bash -c "cat /tmp/secret")

# Register node as Slave
cat <<EOF | java -jar /tmp/jenkins-cli.jar -s ${jenkins_master_url} -auth admin:$PASS create-node $1
<slave>
  <name>$1</name>
  <description></description>
  <remoteFS>/home/jenkins</remoteFS>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.5">
    <host>$1</host>
    <port>22</port>
    <credentialsId>admin</credentialsId>
  </launcher>
  <label>build</label>
  <nodeProperties/>
  <userId>admin</userId>
</slave>
EOF


export TOKEN=$(curl --user "admin:$PASS" -s ${jenkins_master_url}/crumbIssuer/api/json | python -c 'import sys,json;j=json.load(sys.stdin);print j["crumbRequestField"] + "=" + j["crumb"]')

cat > /tmp/secret.groovy <<EOF
for (aSlave in hudson.model.Hudson.instance.slaves) {
  if (aSlave.name == "$1") {
    println aSlave.name + "," + aSlave.getComputer().getJnlpMac()
  }
}
EOF

export SECRET=$(curl --user "admin:$PASS" -d "$TOKEN" --data-urlencode "script=$(</tmp/secret.groovy)" ${jenkins_master_url}/scriptText | awk -F',' '{print $2}')

# Run from service definition
#java -jar slave.jar -jnlpUrl ${jenkins_master_url}/computer/$1/slave-agent.jnlp -secret $SECRET

# write new config
sudo tee /home/jenkins/jenkins-slave/config >/dev/null <<EOF
JENKINS_URL=${jenkins_master_url}
JENKINS_SLAVE=$1
JENKINS_SECRET=$SECRET
EOF

sudo chown jenkins:jenkins /home/jenkins/jenkins-slave

sleep 10

# start the service
sudo service jenkins-slave start