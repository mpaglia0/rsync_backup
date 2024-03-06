#!/bin/bash

# Installation script for rsync_backup
# Copyright (C) Maurizio Paglia

ConfDir=$HOME/.config/rsync_backup

echo "##"
echo "##"
echo "##  Hi! This is the installation script for rsync_backup"
echo "##"
echo "##"

if [ ! -d $ConfDir ]; then
  mkdir -p $ConfDir
else
  if [ -f $ConfDir/rsync_backup.conf ]; then
    echo -e "\nA configuration files has been found found!\nMaybe rsync_backup is already installed?\n"
    #echo -e "If you desire to update rsync_backup please run this installer with option -u or --update\n"
    #echo "Only the backup script will be updated. Configuration files will remain untouched!"
    exit 9
  fi
fi

echo -e "\nWhere rsync_backup exec script has to be copied? (default: "$HOME/bin")"

read InstallDir

InstallDir="${InstallDir:="$HOME/bin"}"

test -d "$InstallDir" || mkdir -p "$InstallDir"

if ! hash rsync 2>/dev/null; then
    echo -e "'rsync' was not found in PATH!\nrsync_backup is based on rsync.\nCannot proceed..."; exit 9
fi

# Copy files in their proper location
cp rsync_backup.sh "$InstallDir" && echo -e "\nBackup script copied in "$InstallDir""...
cp rsync_backup.conf $ConfDir && echo "Config file copied in $ConfDir"...
cp filter_rules $ConfDir && echo "Filter rules for rsync copied in $ConfDir"...

cat >&2 <<EOF

rsync_backup has been installed.

A 'standard' configuration file has been created in $ConfDir
Please open it with a text editor and enter correct values for each parameter.

In order to see the configuration parameters you can run
rsync_backup.sh -p or rsync_backup.sh --print-vars

In order to check the validity of your configuration file you can run
rsync_backup.sh -v or rsync_backup.sh --verify-config

In $ConfDir you will also find a <filter_rules> for rsync filled with
file and directory names that usually do not need a backup.
Please check it before use!

Enjoy!

EOF
