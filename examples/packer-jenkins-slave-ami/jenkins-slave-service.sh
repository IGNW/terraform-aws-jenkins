#!/bin/bash
#
# jenkins-slave Jenkins Build Slave
#
# chkconfig: 345 70 30
# description: Jenkins Build Slave for running Linux builds
# processname: jenkins-slave

# Source function library.
. /etc/init.d/functions

RETVAL=0
prog="jenkins-slave"
LOCKFILE=/var/lock/subsys/$prog

# Declare variables for Jenkins Slave
. /home/jenkins/jenkins-slave/config
JENKINS_USER=jenkins
JENKINS_DIR=/home/$JENKINS_USER/$prog

start() {
        echo -n "Starting $prog: "
        daemon --user $JENKINS_USER java -jar slave.jar -jnlpUrl $JENKINS_URL/computer/$JENKINS_SLAVE/slave-agent.jnlp -secret $JENKINS_SECRET &>dev/null &
        RETVAL=$?
        [ $RETVAL -eq 0 ] && touch $LOCKFILE
        echo
        return $RETVAL
}

stop() {
        echo -n "Shutting down $prog: "
        kill $(pgrep -f "java.*slave.jar.*") && success || failure
        RETVAL=$?
        [ $RETVAL -eq 0 ] && rm -f $LOCKFILE
        echo
        return $RETVAL
}

status() {
        echo -n "Checking $prog status: "
        pgrep -f "java.*slave.jar.*"
        RETVAL=$?
        return $RETVAL
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        stop
        start
        ;;
    *)
        echo "Usage: $prog {start|stop|status|restart}"
        exit 1
        ;;
esac
exit $RETVAL