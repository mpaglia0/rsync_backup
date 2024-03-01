#!/usr/bin/bash

# Backup by E. Ozgur Yilmaz
# Heavily (!) re-written by Maurizio Paglia

# Backs up the harddrives with versioned directories.

######################
#                    #
# Set some variables #
#                    #
######################

PgmName=$(basename .sh)
PgmVer=0.01
ConfDir=$HOME/.config/$PgmName/
ConfFile=$ConfDir/rsync_backup.conf

UserErr=2
SysErr=9
NoErr=0

#############
#           #
# Functions #
#           #
#############

function help() {
clear
cat >&2 <<EOF

$PgmName
Copyright (C) Maurizio Paglia

$PgmName is a Bash script that can also be used as a backup script!

The script looks for a configuration file that have to be adjusted per your needs.
Call <$PgmName -p> or <$PgmName --print-vars> in order to display your own config file.

Usage:

<$PgmName> - the script name. Without parameters NO action will be taken! #todo

Options:

-r --run:         actually execute the backup process.

-c --check:       check the date of the last run and ask the user to launch the script again #todo
                  if more than 30 days (default) were elapsed.
                  This delay can be configured by user.
                  This parameter can be used launching the script automatically (for example from cron) as a reminder.

-nc --new-config: create your own configuration file. #todo
                  This command needs to be launched only once (before the firs use of $PgmName)

-h --help:        display the present help

EOF
exit $NoErr

}

function print_vars() {

echo "Configuration Variables"
echo -e "=======================\n"
echo "RetentionCnt    : ${RetentionCnt}"
echo "BackupSource    : ${BackupSource}"
echo "BackupDisk      : ${BackupDisk}"
echo "BackupTarget    : ${BackupTarget}"
echo "BackupStartDate : ${BackupStartDate}"
echo "GlobalLogFile   : ${GlobalLogFile}"
echo "TempLocalLogFile: ${TempLocalLogFile}"
echo "LocalLogFile    : ${LocalLogFile}"

exit $NoErr

}

function verify_config() {  #change ALL and make it as a onfiguration parameter check

# Create TimeStamp for Backup start date
echo -e "THIS IS A BACKUP SIMULATION.\nNO ACTIONS WILL BE TAKEN!"
echo "==========================="
echo Backup Started at:   $BackupStartDate | tee $TempLocalLogFile >> $GlobalLogFile
echo Backing up $BackupSource to $BackupTarget.0

# Remove the oldest backup
echo Removing oldest backup: $BackupTarget.$RetentionCnt
# rm -rf $BackupTarget.$RetentionCnt

# echo Cascade previous backup folders
# for ((i=RetentionCnt-1;i>=0;i--)); do
#    echo $BackupTarget.$i \-\> $BackupTarget.$((i+1))
#    mv $BackupTarget.$i $BackupTarget.$((i+1))
#done

echo Link and Copy $BackupTarget.0
#cp -rl $BackupTarget.1 $BackupTarget.0

echo Running rsync command in quiet mode
#/usr/bin/rsync -avuh --progress --delete-excluded --delete --filter="merge filter_rules" $BackupSource $BackupTarget.0/ | tee -a $TempLocalLogFile

# Create TimeStamp for Backup end date
# echo Backup Completed at: `date +"%Y%m%d-%H%M"` | tee -a $TempLocalLogFile >> $GlobalLogFile
# echo "==================================" >> $GlobalLogFile

# Move the TempLocalLogFile to LocalLogFile
#mv $TempLocalLogFile $LocalLogFile

echo "Backup Completed"

}

function dry_run() {

# link and copy and backup
rsync -avuhn --progress --delete-excluded --delete --filter="merge filter_rules" $BackupSource $BackupTarget.0/ | tee ./whatToBackup

echo "Dry Run Completed!"

}

function backup_continue() {

# Create TimeStamp for Backup start date
echo Backup Started at:   $BackupStartDate | tee $TempLocalLogFile >> $GlobalLogFile
echo Backing up $BackupSource to $BackupTarget.0

# echo Running rsync command in quiet mode
/usr/bin/rsync -avuh --progress --delete-excluded --delete --filter="merge filter_rules" $BackupSource $BackupTarget.0/ | tee -a $TempLocalLogFile

# Create TimeStamp for Backup end date
echo Backup Completed at: `date +"%Y%m%d-%H%M"` | tee -a $TempLocalLogFile >> $GlobalLogFile
echo "==================================" >> $GlobalLogFile

# Move the TempLocalLogFile to LocalLogFile
mv $TempLocalLogFile $LocalLogFile

echo "Backup Completed"

}

function remove_latest_backup() {

# Remove the latest backup
echo Removing latest backup: $BackupTarget.0
rm -rf $BackupTarget.0

echo Cascade previous backup folders
for ((i=1;i<RetentionCnt;i++)); do
    echo $BackupTarget.$i \-\> $BackupTarget.$((i-1))
    mv $BackupTarget.$i $BackupTarget.$((i-1))
done

echo Removed latest backup folder succesfully!

}

function remove_oldest_backup() {

# Remove the oldest backup
echo Removing the oldest backup folder
for ((i=RetentionCnt;i>5;i--)); do
    # echo Looking for $BackupTarget.$i
    if [ -d $BackupTarget.$i ]; then
        echo Found $BackupTarget.$i as the oldest
        echo Removing $BackupTarget.$i
        rm -Rf $BackupTarget.$i
        break
    fi
done

echo Removed oldest backup folder succesfully!

}

function run () {
# Create TimeStamp for Backup start date
echo Backup Started at:   $BackupStartDate | tee $TempLocalLogFile >> $GlobalLogFile
echo Backing up $BackupSource to $BackupTarget.0

# Remove the oldest backup
echo Removing oldest backup: $BackupTarget.$RetentionCnt
rm -rf $BackupTarget.$RetentionCnt

echo Cascade previous backup folders
for ((i=RetentionCnt-1;i>=0;i--)); do
    echo $BackupTarget.$i \-\> $BackupTarget.$((i+1))
    mv $BackupTarget.$i $BackupTarget.$((i+1))
done

echo Link and Copy $BackupTarget.0
cp -rl $BackupTarget.1 $BackupTarget.0

echo Running rsync command in quiet mode
/usr/bin/rsync -avuh --progress --delete-excluded --delete --filter="merge filter_rules" $BackupSource $BackupTarget.0/ | tee -a $TempLocalLogFile


# Create TimeStamp for Backup end date
echo Backup Completed at: `date +"%Y%m%d-%H%M"` | tee -a $TempLocalLogFile >> $GlobalLogFile
echo "==================================" >> $GlobalLogFile

# Move the TempLocalLogFile to LocalLogFile
mv $TempLocalLogFile $LocalLogFile

echo "Backup Completed"

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
	-r|--run)
	   run
		;;
    *)
		echo -e "\nNothing to do... You need to pass at least one argument!"
		echo "Or, maybe, you used a non valid argument..."
		echo -e "Try <$PgmName -h> or <$PgmName --help> for further info.\n"
		exit $SysErr
		;;
	esac
done
