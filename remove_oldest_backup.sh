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
