#!/bin/bash

# Installation script for rsync_backup
# Copyright 2024 Maurizio Paglia

PgmName=$(basename .sh)
PgmVer=0.01
ConfDir=$HOME/.config/rsync_backup

echo ##
echo ##
echo ##  Hi! This is the installation script for $PGMNAME, v.$PGMVER
echo ##
echo ##

if [ ! -d $ConfDir ]; then
  mkdir -p $ConfDir
else
  if [ -f $ConfDir/config ]; then
    echo -e "\nA configuration files has been found found!\nMaybe $PgmName is already installed?\n"
    exit 9
  fi
fi

# test if rsync executable exists

# Copy files in their proper location

# Launch the config-test script

(study a config file guided fill)
