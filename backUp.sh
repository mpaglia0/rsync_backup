#!/usr/bin/bash
#
# Backup by E.Ozgur Yilmaz
#
# Backs up the harddrives with versioned directories.
#


#############
#           #
# Functions #
#           #
#############

function help() {
clear
cat >&2 <<EOF

$PGMNAME
Copyright (C) Maurizio Paglia

$PGMNAME is a very simple Bash script that will help you to sync data accross directories.
Is it NOT intended to be a backup script!
You can find a lot of first-clss backups scripts/programs ouf of there...

The script needs a configuration file that can be adjusted per your needs.
Call <$PGMNAME -cc> or <$PGMNAME --create-config> in order to create your own config file.

Usage:

<$PGMNAME> - the script name. Without parameters NO action will be taken!

Options:

-r --run:         actually execute the synchronization process.

-c --check:       check the date of the last run and ask the user to launch the script again
                  if more than 30 days (default) were elapsed.
                  This delay can be configured by user.
                  This parameter can be used launching the script automatically (for example from cron) as a reminder.

-nc --new-config: create your own configuration file.
                  This command needs to be launched only once (before the firs use of $PGMNAME)

-h --help:        display the present short help

EOF
exit $SUCCESS
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
	-vc|--verify-config)
		verify_config
		;;
	-h|--help)
		help
		;;
	-dr|--dry-run)
        dry_run
        ;;
    *)
		echo -e "\nNothing to do... You need to pass at least one argument!"
		echo "Or, maybe, you used a non valid argument..."
		echo -e "Try <$PGMNAME -h> or <$PGMNAME --help> for further info.\n"
		exit $SYSERR
		;;
	esac
done


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
