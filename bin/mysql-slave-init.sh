#!/bin/bash

###################################################
# Centreon                                Juin 2017
#
# Initialisation du Slave
#
###################################################

. /usr/share/centreon-ha/lib/mysql-functions.sh
. /etc/centreon-ha/mysql-resources.sh

usage()
{
echo
echo "Use : $0 <master_log_file> <master_log_pos>"
echo
}

cmd_line()
{
if [ $# -ne 2 ]
then
        usage
        exit 1
fi

MASTER_LOG_FILE=$1
MASTER_LOG_POS=$2
}

slave_init()
{
	MASTER_DBHOSTNAME=$(get_other_db_hostname)
        get_ip "$MASTER_DBHOSTNAME" > /dev/null
        mysql -f -u "$DBROOTUSER" -h "$PARAM_DBHOSTNAME" "-p$DBROOTPASSWORD" << EOF
SET GLOBAL read_only = ON;
RESET MASTER;
SLAVE STOP;
RESET SLAVE;
CHANGE MASTER TO MASTER_HOST='$MASTER_DBHOSTNAME', MASTER_USER='$DBREPLUSER', MASTER_PASSWORD='$DBREPLPASSWORD', MASTER_LOG_FILE='$MASTER_LOG_FILE', MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;
show processlist;
quit
EOF
}

#
# Main
#
cmd_line $*

# Initialisation du slave
slave_init
