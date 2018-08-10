#!/bin/bash
# MySQL databases migration script
# Jorge Barnaby (jorge {dot} barnaby {at} gmail)

################################################################################
# Configuration variables

ORIG_USER="LOCAL_DB_USER"
ORIG_PASS="LOCAL_DB_PASS"
ORIG_HOST="LOCAL_DB_HOST"

DEST_USER="DESTINATION_USER"
DEST_PASS="DESTINATION_USER_PAS"
DEST_HOST="DESTINATION_HOST"

# Do not backup the following databases
IGNORED_DBS="information_schema"

################################################################################
# Start of the program

# Command that runs on the origin server to extract the databases
MYSQL_ORIG="mysqldump -u $ORIG_USER -h $ORIG_HOST -p$ORIG_PASS --add-drop-database --databases"

# Command that runs on the destination server to popuplate the databases
MYSQL_DEST="mysql -u $DEST_USER -h $DEST_HOST -p$DEST_PASS"

# Get all database list first
DBS="$(mysql -u $ORIG_USER -h $ORIG_HOST -p$ORIG_PASS -Bse 'show databases')"

echo
echo -----------------------------------------------------------
echo `date +"%F %T %Z"` : Starting MySQL Migration script
echo -----------------------------------------------------------
echo
echo -- MySQL Origin Server: $ORIG_HOST
echo -- MySQL Destination Server: $DEST_HOST

for db in $DBS
do
    skipdb=-1
    if [ "$IGNORED_DBS" != "" ];
    then
        for i in $IGNORED_DBS
        do
            [ "$db" == "$i" ] && skipdb=1 || :
        done
    fi

    if [ "$skipdb" == "-1" ];
    then
        echo
        echo -- `date +"%F %T %Z"` : Migrating database $db
        # Command to be executed piping mysqldump on the origin and mysql on the remote
        $MYSQL_ORIG $db | $MYSQL_DEST
        echo -- `date +"%F %T %Z"` : Done
    fi
done

echo
echo -----------------------------------------------------------
echo `date +"%F %T %Z"` : All Done
echo -----------------------------------------------------------

exit 0
