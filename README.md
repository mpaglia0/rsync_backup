# rsync_backup

:warning: under development!

This is a ``rsync`` based incremental backup system written for Linux Bash.

It is furnished with an install script that copies on your HD:

- ``rsync_backup.sh`` (default in ``$HOME/bin`` but you can choose a different directory)
- ``rsync_backup.conf`` in ``$HOME/.config/rsync_backup`` this is your configuration file
- ``filter_rules`` in ``$HOME/.config/rsync_backup`` this is a filter for ``rsync``

Script options:

- Print variables stored in ``rsync_backup.conf`` (for debug purposes).
- Run a configuration test in order to see if all parameters are valid (for debug purposes).
- Perform a Dry Run (simulate a backup) to see if backup procedure has been configure properly (for debug purposes).
- Manually remove oldest or latest backup

Simply run ``rsync_backup.sh -h | --help`` and see all available options.

:warning: ``filter_rules`` require a good knowledge of filtering options in ``rsync``. Please use ``man rsync`` or search filter options/examples on the Internet
in order to correctly fill this configuration file.
