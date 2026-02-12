#!/bin/bash

# This is the script that I

# ---------- Configuration ----------
# This is how the config.sh file should look like


#DEFAULT_USER=
#DEFAULT_HOST=
#SRC_DIR=
#DEST_DIR=

# Setup Commands
#SETUP_COMMANDS=()

# ---------- Load external config ----------
CONFIG_FILE="./config.sh"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# ---------- Utility Functions ----------
# Functions to timestamp when log in
timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log() {
    echo "[$(timestamp)] $1"
}

# ---------- Steps ----------
# Open Password Manager
launch_keepass() {
    if command -v keepassxc >/dev/null 2>&1; then
        log "Launching KeePassXC..."
        keepassxc &
    else
        log "KeePassXC is not installed. Skipping launch."
    fi
}

# This function I use to sync files from the local machine to the remote machine in the ssh connection
sync_files() {
    log "Do you want to sync local files to the remote machine?"
    echo "    Source: $SRC_DIR"
    echo "    Destination: $REMOTE:$DEST_DIR"
    read -rp "Sync files? (y/n): " sync_answer

    if [[ "$sync_answer" =~ ^[Yy]$ ]]; then
        log "Running rsync to $REMOTE:$DEST_DIR..."
        rsync -avhP "$SRC_DIR" "$REMOTE:$DEST_DIR"
    else
        log "Skipping file sync."
    fi
}

# This function asks wich of the setup commands to run the ssh connection is stablished
ask_and_ssh() {
    REMOTE_CMDS=""

    for cmd in "${SETUP_COMMANDS[@]}"; do
        log "Do you want to run the following command after SSH connects?"
        echo "    $cmd"
        read -rp "Run this command? (y/n): " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            REMOTE_CMDS+="$cmd; "
        fi
    done

    if [[ -n "$REMOTE_CMDS" ]]; then
        log "Connecting and running selected setup commands..."
        ssh -t "$USER@$HOST" "$REMOTE_CMDS bash --login"
    else
        log "No setup commands selected."
        echo "Reminder: After connecting, you may want to run:"
        for cmd in "${SETUP_COMMANDS[@]}"; do
            echo "    $cmd"
        done
        echo ""
        log "Connecting to $USER@$HOST..."
        ssh -t "$USER@$HOST"
    fi
}

sync_from_remote() {
    log "Do you want to sync remote files back to your local machine?"
    echo "    Remote: $REMOTE:$REMOTE_OUTPUT_DIR"
    echo "    Local:  $LOCAL_OUTPUT_DIR"
    read -rp "Sync from remote? (y/n): " answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        log "Syncing from remote..."
        rsync -avhP "$REMOTE:$REMOTE_OUTPUT_DIR" "$LOCAL_OUTPUT_DIR"
    else
        log "Skipping remote-to-local sync."
    fi
}



# ---------- Main ----------
USER="${1:-$DEFAULT_USER}"
HOST="${2:-$DEFAULT_HOST}"
REMOTE="$USER@$HOST"

launch_keepass
sync_files
ask_and_ssh
sync_from_remote