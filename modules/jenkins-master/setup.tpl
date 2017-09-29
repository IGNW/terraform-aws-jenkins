#!/bin/bash
set -e -x
# This script is meant to be run in the User Data of each EC2 Instance while it's booting.

function waitForJenkins() {
    echo "Waiting jenkins to launch on 8080..."

    while ! nc -z localhost 8080; do
      sleep 0.1 # wait for 1/10 of the second before check again
    done

    echo "Jenkins launched"
}
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

sudo service jenkins start
sudo chkconfig --add jenkins

waitForJenkins

# UPDATE PLUGIN LIST
curl  -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @- http://localhost:8080/updateCenter/byId/default/postBack