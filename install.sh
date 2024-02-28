#!/bin/bash

# Installation script for rsync_backup
# Copyright 2024 Maurizio Paglia

PGMNAME=$(basename .sh)
PGMVER=1.0
CONFDIR=$HOME/.config/rsync_backup

echo ##
echo ##
echo ##  Hi! This is the installation script for $PGMNAME, v.$PGMVER
echo ##
echo ##

if [ ! -d $CONFDIR ]; then
  mkdir -p $CONFDIR
else
  if [ -f $CONFDIR/config ]; then
    echo -e "\nA configuration files has been found found!\nMaybe $PGMNAME is already installed?\n"
    exit 9
  fi
fi

# test if rsync executable exists
