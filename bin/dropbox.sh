#! /usr/bin/env bash
: ${DROPBOX_DIR=$HOME/Dropbox}
: ${DROPBOX_REMOTE=Dropbox}

rclone --verbose --checksum bisync "$DROPBOX_DIR" "$DROPBOX_REMOTE:" $@

if [ $? -eq 2 ]; then
    rclone --verbose --checksum bisync --resync "$DROPBOX_DIR" "$DROPBOX_REMOTE:" $@
fi
