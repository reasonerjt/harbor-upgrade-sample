#!/bin/bash
set -e
#Verify Harbor is installed on the target directory and can be upgraded using this script.
validate() {
    echo "Validating Harbor installation directory: $1 for upgrade..."
    if [ ! -d $1 -o ! -f $1/docker-compose.yml ]; then
        echo "Harbor is not installed in directory $1, exit"
        exit 1
    fi
    current_version=`cat $1/docker-compose.yml | grep image | grep vmware | head -1 | cut -d: -f3`
    echo "Current version of Harbor: $current_version"
    #TODO: verify the version of Harbor if needed"
}
new_version=0.5.0
echo "This script will upgrade your Harbor instance to $new_version, please make sure you've taken snapshot before continueing"
read -p "Please input y to continue, other keys to exit:" ans
if [ "$ans" != "y" ]; then
    echo "Exiting..."
    exit 0
fi
if [ $# = 1 ]; then
    HARBOR_BASEDIR=$1
elif [ $# = 0 ]; then
    HARBOR_BASEDIR="/harbor/harbor"
fi
echo "harbor basedir $HARBOR_BASEDIR"
validate $HARBOR_BASEDIR
echo "Shutting down Harbor"
docker-compose -f $HARBOR_BASEDIR/docker-compose.yml down 
#Back up
if [ ! -d $HARBOR_BASEDIR/../harbor-bak ]; then
    mkdir $HARBOR_BASEDIR/../harbor-bak
fi
count=0
HARBOR_BAK_DIR="$HARBOR_BASEDIR/../harbor-bak/`date +%F`"
while [ -d $HARBOR_BAK_DIR ]; do
    let count=count+1
    HARBOR_BAK_DIR="$HARBOR_BASEDIR/../harbor-bak/`date +%F`-$count"
done
echo "The backup directory: $HARBOR_BAK_DIR"
mkdir $HARBOR_BAK_DIR
UPGRADE_BASEDIR=`dirname $0`
# Backup DB if db migration is required ##
echo "Backup the current installation..."
DB_USR=root
DB_PWD=$(ovfenv -k db_password)
mkdir $HARBOR_BAK_DIR/db
echo "Loading the db migrator image..."
docker load -i $UPGRADE_BASEDIR/images/harbor-db-migrator.tgz
echo "Backup the database..."
docker run -ti --rm -e DB_USR=$DB_USR -e DB_PWD=$DB_PWD -v /data/database:/var/lib/mysql -v $HARBOR_BAK_DIR/db:/harbor-migration/backup vmware/harbor-db-migrator backup
mv $HARBOR_BASEDIR/* $HARBOR_BAK_DIR/
############################################
cp -fr $UPGRADE_BASEDIR/assets/* $HARBOR_BASEDIR/
#If DB migration is required
docker run -ti --rm -e DB_USR=$DB_USR -e DB_PWD=$DB_PWD -e SKIP_CONFIRM=y -v /data/database:/var/lib/mysql vmware/harbor-db-migrator up head
echo "Loading new Harbor images..."
docker load -i $UPGRADE_BASEDIR/images/harbor-images.tgz
#If necessary tag the unchanged image to latest version locally
#....
#Migrate harbor.cfg if it's changed.
$UPGRADE_BASEDIR/migrate_harborcfg.py $HARBOR_BAK_DIR/harbor.cfg $HARBOR_BASEDIR/harbor.cfg
cd $HARBOR_BASEDIR
./prepare
docker-compose up -d
echo "Harbor has been upgraded to $new_version"

