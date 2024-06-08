#!/usr/bin/bash

# Backup by E. Ozgur Yilmaz
# Heavily (!) re-written by Maurizio Paglia

# Backs up the harddrives with versioned directories.

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

##############
#            #
# Set colors #
#            #
##############

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
# Clear the color
clear='\033[0m'

#####################################
#                                   #
# First of all a quick sanity check #
#                                   #
#####################################

# Check if rsync is installed and found in PATH
if ! hash rsync 2>/dev/null; then
    echo -en "\n${red}ERR:${clear} 'rsync' was not found in PATH! Cannot proceed ..."; exit $SysErr
fi

# Check if configuration folder exists
if [ ! -d $ConfDir ]; then
	echo -en "\n${red}ERR:${clear} Cannot find the configuration directory ..."
	echo "Maybe you need to check $ShortPgmName installation first!"
	exit $SysErr
fi

# Import the configuration file
# sed removes empty and commented lines

ConfParms=$(cat $ConfFile | sed -e 's/\s*$//' -e '/^$/d' -e '/^#.*$/d')

eval "$ConfParms"

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

$PgmName is a Bash backup script.

The script looks for a configuration file that have to be adjusted per your needs.
Call <$PgmName -p> or <$PgmName --print-vars> in order to display your own configuration variables.

Usage:

<$PgmName> - Without parameters NO action will be taken!

Options:

-p --print-vars      - Print variables entered in $ConfFile
                       Only for debug purposes.

-v --verify-config   - Verify all configuration parameters are OK and try to handle errors.
                     - After $ShortPgmName installation this is a suggested step!
                       A lot of information messages will be printed on screen.

-d --dry-run         - Actually run a backup but write (save) nothing!
                       Backup messages will be printed on screen.
                       Only for debug purposes.

-rl --remove-latest  - Removes latest backup directory.

-ro --remove-oldest  - Removes oldest backup directory.

-e --exec            - Actually executes the backup.

-h --help            - Display the present help.

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
	echo -e "This file is stored instead, so you have to look for information here!\n"
else
	echo -en "${red}ERR:${clear} BackupDisk does not exist!"
	echo "Please check this is the backup destination you desire,"
	echo "and create it if this path is correct. Maybe you only need"
	echo "to check and amend variable <BackupDisk> in configuration file"
	echo -e "or mount the medium.\n"
	exit $SysErr
fi

if [ -d $BackupSource ]; then
	echo "$BackupSource is the folder that will backed up (the backup source)."
	echo "$BackupTarget is the name of the backup folder."
	echo -e "Since backups are incremental any new backup will be named $BackupTarget.0\n"
else
	echo -en "${red}ERR:${clear} $BackupSource does not exist!"
	echo -e "Please fill variable <BackupSource> in configuration file.\n"
	exit $SysErr
fi

echo "The variable <RetentionCnt> indicates the quantity of backups to keep"
echo -e "so the oldest backup will be named $BackupTarget.$RetentionCnt\n"

if [ $KeepDryRunTest -eq 0 ]; then
	echo -en "${yellow}INFO:${clear} <KeepDryRunTest> has been set to <0>"
	echo -e "\nDry run output will be displayed but not saved in a file.\n"
elif [ $KeepDryRunTest -eq 1 ]; then
	echo -en "${yellow}INFO:${clear} <KeepDryRunTest> has been set to <1>"
	echo -e "\nDry run output will be displayed AND saved in a file."
	echo -e "Output file is <./whatToBackup>.\n"
else
	echo -en "${red}ERR:${clear} <KeepDryRunTest> has a wrong parameter!"
	echo -e "Please check your configuration file.\n"
	exit $SysErr
fi

echo -en "${green}OK:${clear} your configuration seems to work correctly!\n"

exit $NoErr

}

function check_media() {

if [ ! -d $BackupDisk ]; then
	echo -en "\n${red}ERR:${clear} Cannot find the backup media ..."
	echo "Maybe you need to mount it first!"
	exit $SysErr
fi

}

function find_max() {

check_media

BaseBackupTarget=$(dirname "$BackupTarget")

MaxBck=$(ls -l "$BaseBackupTarget" | grep ^d | wc -l)

if [ $MaxBck = $RetentionCnt ]; then
	echo -en "\n${yellow}INFO:${clear} Max backup quantities ($MaxBck) reached!"
	return 0
else
	echo -en "\n${yellow}INFO:${clear} Max session on target $BaseBackupTarget is $MaxBck"
	return 0
fi

}

function dry_run() {

clear

check_media

echo -en "\n${yellow}INFO:${clear} Simulate rsync backup execution!\n"

rsync -avuhn --progress --delete-excluded --delete --filter="merge $ConfDir/filter_rules" $BackupSource $BackupTarget.0/ | tee ./whatToBackup

if [ $KeepDryRunTest -eq 0 ]; then
	rm ./whatToBackup
fi

echo -en "\n${green}OK:${clear} Dry Run completed successfully!\n"

exit $NoErr

}

function remove_latest() {

clear

check_media

find_max

# Remove the latest backup
echo -en "\n${yellow}INFO:${clear} Removing latest backup: $BackupTarget.0 ... please wait ..."
rm -rf "$BackupTarget".0 && echo -en "\n${green}OK:${clear} Removed latest backup folder successfully!"

echo -e "\nCascade previous backup folders ...\n"

for ((i=1;i<$MaxBck;i++)); do
    echo "$BackupTarget".$i \-\> "$BackupTarget".$((i-1))
    mv "$BackupTarget".$i "$BackupTarget".$((i-1))
done

echo -en "\n${green}OK:${clear} Backup structure successfully restored!\n"

exit $NoErr

}

function remove_oldest() {

clear

check_media

echo -en "\n${yellow}INFO:${clear} Removing the oldest backup folder.\n"

find_max

echo -e "\nFound $BackupTarget.$MaxBck as the oldest."
echo "Removing $BackupTarget.$MaxBck ... please wait ..."
rm -rf $BackupTarget.$MaxBck && echo -en "\n${green}OK:${clear} Removed oldest backup folder successfully!\n"

exit $NoErr

}

function exec () {

clear

check_media

find_max

# Create TimeStamp for Backup start date

echo "Backup Started at:   $BackupStartDate" | tee $TempLocalLogFile >> $GlobalLogFile
echo -en "\n${yellow}INFO:${clear} Backing up $BackupSource to $BackupTarget.0\n"

# Remove the oldest backup

if [ -d $BackupTarget.$RetentionCnt ]; then
	echo -en "\n${yellow}INFO:${clear} Removing oldest backup: $BackupTarget.$RetentionCnt"
	rm -rf $BackupTarget.$RetentionCnt
fi

echo -en "\n${yellow}INFO:${clear} Cascade previous backup folders ...\n"
for ((i=$MaxBck-1;i>=0;i--)); do
    echo $BackupTarget.$i \-\> $BackupTarget.$((i+1))
    mv $BackupTarget.$i $BackupTarget.$((i+1))
done

echo -en "\n${yellow}INFO:${clear} Link and Copy $BackupTarget.0 ...\n"
cp -rl $BackupTarget.1 $BackupTarget.0

echo -en "\n${yellow}INFO:${clear} Running rsync command in quiet mode\n"
/usr/bin/rsync -avuh --progress --delete-excluded --delete --filter="merge $ConfDir/filter_rules" $BackupSource $BackupTarget.0/ | tee -a $TempLocalLogFile


# Create TimeStamp for Backup end date

echo "Backup Completed at:   `date +"%Y-%m-%d_%H:%M"`" | tee -a $TempLocalLogFile >> $GlobalLogFile
echo "==================================" >> $GlobalLogFile

# Move the TempLocalLogFile to LocalLogFile

mv $TempLocalLogFile $LocalLogFile

echo -en "\n${green}OK:${clear} Backup Completed\n"

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
