#Upgrade Guide

This guide will help you upgrade a Harbor instance which is installed by .ova package.

##Steps:
1) Before the upgrade, it's recommended to take snapshot of the Harbor instance from your vCenter, such that if the upgrade process fails, it'll be easier to roll back.

2) Login to Harbor instance via console or ssh, and copy the upgrade tarball to Harbor instance, and untar for example

```
# scp root@10.117.4.174:/root/harbor_050_upgrade.tgz /root/
# cd /root
# tar xvf ./harbor_050_upgrade.tgz
```

3) You would get a directory called "harbor-upgrade-0.5.0", go to the directory and execute the script `upgrade.sh`:

```
# cd harbor-upgrade-0.5.0
# ./upgrade.sh
```

4) When prompted, make sure you've taken the snapshot, and press y and hit Enter to continue:

```
# ./upgrade.sh
This script will upgrade your Harbor instance to 0.5.0, please make sure you've taken snapshot before continueing
Please input y to continue, other keys to exit: y
```

5) The script will automatically shutdown Harbor, perform the upgrade and start Harbor again.

6) After Harbor is successfully upgraded, it's recommended to remove the tarball and directory "harbor-upgrade-0.5.0" to free up the space of the disk.