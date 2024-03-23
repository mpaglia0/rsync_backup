#!/usr/bin/bash

# Backup by E. Ozgur Yilmaz
# Heavily (!) re-written by Maurizio Paglia

# Backs up the harddrives with versioned directories.

#####################################
#                                   #
# First of all a quick sanity check #
#                                   #
#####################################

if ! hash rsync 2>/dev/null; then
    echo "'rsync' was not found in PATH! Cannot proceed..."; exit $SysErr
fi

######################
#                    #
# Set some variables #
#                    #
######################

PgmName=$(basename $0)
ShortPgmName=$(basename $0 | cut -d. -f1)
PgmVer=0.01
ConfDir=$HOME/.config/$ShortPgmName/
ConfFile=$ConfDir/rsync_backup.conf
BackupStartDate=$(date +"%Y-%m-%d_%H:%M")

UserErr=2
SysErr=9
NoErr=0

# Import the configuration file
# sed removes empty and commented lines

ConfParms=$(cat $ConfFile | sed -e 's/\s*$//' -e '/^$/d' -e '/^#.*$/d')

eval $ConfParms

#############
#           #
# Functions #
#           #
#############

function help() {

clear

cat >&2 <<EOF

$PgmName
Copyright (C) $(date +%Y) Maurizio Paglia

$PgmName is a Bash script that can also be used as a backup script!

The script looks for a configuration file that have to be adjusted per your needs.
Call <$PgmName -p> or <$PgmName --print-vars> in order to display your own config file.

Usage:

<$PgmName> - Without parameters NO action will be taken!

Options:

-p --print-vars      - Print variables entered in $ConfFile
                       Only for debug purposes.

-v --verify-config   - Simulate a backup in order to verify all configuration parameters are OK.
                       A lot of information messages will be printed on screen.

-d --dry-run         - Actually run a backup but write (save) nothing!
                       Backup messages will be printed on screen.
                       Only for debug purposes.

-rl --remove-latest  - Removes latest backup directory.

-ro --remove-oldest  - Removes oldest backup directory

-e --exec            - Actually executes the backup.

-h --help            - Display the present help

EOF

exit $NoErr

}

function print_vars() {

clear

echo -e "\nConfiguration Variables"
echo -e "=======================\n"
echo "RetentionCnt      : $RetentionCnt"
echo "BackupSource      : $BackupSource"
echo "BackupDisk        : $BackupDisk"
echo "BackupTarget      : $BackupTarget"
echo "GlobalLogFile     : $GlobalLogFile"
echo "TempLocalLogFile  : $TempLocalLogFile"
echo "LocalLogFile      : $LocalLogFile"
echo "KeepDryRunTest    : $KeepDryRunTest"
echo -e "\nFrom installation process"
echo -e "=========================\n"
echo "PgmName           : $PgmName"
echo "WorkDir           : $(dirname $(which $0))"
echo "ConfDir           : $ConfDir"

exit $NoErr

}

function verify_config() {

clear

echo -e "\nTHIS IS A CONFIGURATION TEST.\n  NO ACTIONS WILL BE TAKEN!"
echo -e "=============================\n"
echo "Backup Start date: $BackupStartDate"
echo -e "This is always today's date/time.\n"

if [ -d $BackupDisk ]; then
	echo "$TempLocalLogFile - This is a temp log."
	echo "It will be used by the script and destroyed before its end."
	echo "All operations will be actually logged in $GlobalLogFile"
	echo -e "This file is stored, so you have to look for information here!\n"
else
	echo "$BackupDisk does not exist!"
	echo "Please check this is the backup destination you desire,"
	echo "and create it if this path is correct. Maybe you only need"
	echo "to check and amend variable <BackupDisk> in configuration file.\n"
	exit $SysErr
fi

if [ -d $BackupSource ]; then
	echo "$BackupSource is the folder that will backed up (the backup source)."
	echo "$BackupTarget is the name of the backup file."
	echo -e "Since backups are incremental any new backup will be named $BackupTarget.0\n"
else
	echo "$BackupSource does not exist!"
	echo -e "Please fill variable <BackupSource> in configuration file.\n"
	exit $SysErr
fi

echo "The variable <RetentionCnt> indicates the quantity of backups to keep"
echo -e "so the oldest backup will be named $BackupTarget.$RetentionCnt\n"

if [ $KeepDryRunTest -eq=0 ]; then
	echo "<KeepDryRunTest> has been set to <0>"
	echo -e "Dry run output will be displayed but not saved in a file.\n"
elif [ $KeepDryRunTest -eq 1 ]; then
	echo "<KeepDryRunTest> has been set to <1>"
	echo "Dry run output will be displayed AND saved in a file."
	echo -e "Output file is <./whatToBackup>.\n"
else
	echo "<KeepDryRunTest> has a wrong parameter!"
	echo -e "Please check your configuration file.\n"
	exit $SysErr
fi

echo "Well done: your configuration seems to work correctly!"

exit $NoErr

}

function dry_run() {

clear

echo -e "Simulate rsync backup execution!\n"

rsync -avuhn --progress --delete-excluded --delete --filter="merge $ConfDir/filter_rules" $BackupSource $BackupTarget.0/ | tee ./whatToBackup

if [ $KeepDryRunTest -eq 0 ]; then
	rm ./whatToBackup
fi

echo "Dry Run Completed!"

exit $NoErr

}

function backup_continue() { #????

clear

# Create TimeStamp for Backup start date

echo Backup Started at:   $BackupStartDate | tee $TempLocalLogFile >> $GlobalLogFile
echo Backing up $BackupSource to $BackupTarget.0

# echo Running rsync command in quiet mode

/usr/bin/rsync -avuh --progress --delete-excluded --delete --filter="merge $ConfDir/filter_rules" $BackupSource $BackupTarget.0/ | tee -a $TempLocalLogFile

# Create TimeStamp for Backup end date

echo Backup Completed at:   `date +"%Y-%m-%d_%H:%M"` | tee -a $TempLocalLogFile >> $GlobalLogFile
echo "==================================" >> $GlobalLogFile

# Move the TempLocalLogFile to LocalLogFile

mv $TempLocalLogFile $LocalLogFile

echo "Backup Completed"

exit $NoErr

}

function remove_latest() { #chech echoes

clear

# Remove the latest backup

echo "Removing latest backup: $BackupTarget.0"
rm -rf $BackupTarget.0

echo "Cascade previous backup folders..."
for ((i=1;i<RetentionCnt;i++)); do
    echo $BackupTarget.$i \-\> $BackupTarget.$((i-1))
    mv $BackupTarget.$i $BackupTarget.$((i-1))
done

echo "Removed latest backup folder successfully!"

exit $NoErr

}

function remove_oldest() { #check echoes

# Remove the oldest backup

echo "Removing the oldest backup folder"
for ((i=RetentionCnt;i>5;i--)); do
    # echo Looking for $BackupTarget.$i
    if [ -d $BackupTarget.$i ]; then
        echo "Found $BackupTarget.$i as the oldest"
        echo "Removing $BackupTarget.$i ..."
        rm -Rf $BackupTarget.$i
        break
    fi
done

echo "Removed oldest backup folder successfully!"

exit $NoErr

}

function exec () { #check echoes

clear

# Create TimeStamp for Backup start date

echo "Backup Started at:   $BackupStartDate" | tee $TempLocalLogFile >> $GlobalLogFile
echo "Backing up $BackupSource to $BackupTarget.0"

# Remove the oldest backup

echo "Removing oldest backup: $BackupTarget.$RetentionCnt"
rm -rf $BackupTarget.$RetentionCnt

echo "Cascade previous backup folders"
for ((i=RetentionCnt-1;i>=0;i--)); do
    echo $BackupTarget.$i \-\> $BackupTarget.$((i+1))
    mv $BackupTarget.$i $BackupTarget.$((i+1))
done

echo "Link and Copy $BackupTarget.0"
cp -rl $BackupTarget.1 $BackupTarget.0

echo "Running rsync command in quiet mode"
/usr/bin/rsync -avuh --progress --delete-excluded --delete --filter="merge $ConfDir/filter_rules" $BackupSource $BackupTarget.0/ | tee -a $TempLocalLogFile


# Create TimeStamp for Backup end date

echo "Backup Completed at:   `date +"%Y-%m-%d_%H:%M"`" | tee -a $TempLocalLogFile >> $GlobalLogFile
echo "==================================" >> $GlobalLogFile

# Move the TempLocalLogFile to LocalLogFile

mv $TempLocalLogFile $LocalLogFile

echo "Backup Completed"

exit $NoErr

}

###################################
#                                 #
#  Evaluate command line options  #
#                                 #
###################################

while true; do
	case "$1" in
	-p|--print-vars)
		print_vars
		;;
	-v|--verify-config)
		verify_config
		;;
	-h|--help)
		help
		;;
	-d|--dry-run)
      dry_run
      ;;
	-e|--exec)
	   exec
		;;
	-rl|--remove-latest)
		remove_latest
		;;
	-ro|--remove-oldest)
		remove_oldest
		;;
    *)
		echo -e "\nNothing to do... You need to pass at least one argument!"
		echo "Or, maybe, you used a non valid argument..."
		echo -e "Try <$PgmName -h> or <$PgmName --help> for further info.\n"
		exit $SysErr
		;;
	esac
done
