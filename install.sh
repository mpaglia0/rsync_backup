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
  if [ -f $ConfDir/rsync_backup.conf ]; then
    echo -e "\nA configuration files has been found found!\nMaybe $PgmName is already installed?\n"
    exit 9
  fi
fi

echo -e "\nWhere copy $PgmName exec script? (default: "$HOME/bin")"

read InstallDir

InstallDir="${InstallDir:="$HOME/bin"}"

test -d "$InstallDir" || mkdir -p "$InstallDir"

if ! hash rsync 2>/dev/null; then
    echo "'rsync' was not found in PATH! Cannot proceed..."; exit 9
fi

# Copy files in their proper location

# Launch the config-test script

(study a config file guided fill)


# Import the configuration file

ConfContent=$(cat $ConfDir/rsync_backup.conf | sed '/^#/d')
eval "$ConfContent"
