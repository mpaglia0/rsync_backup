function dry_run() {

# link and copy and backup
rsync -avuhn --progress --delete-excluded --delete --filter="merge filter_rules" $BackupSource $BackupTarget.0/ | tee ./whatToBackup

echo "Dry Run Completed!"

}
