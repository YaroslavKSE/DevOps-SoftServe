#!/bin/bash

LOG_FILE="/var/log/sftp_file_creation.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

CURRENT_SERVER=$(hostname)

SERVERS=("192.168.33.11" "192.168.33.12" "192.168.33.13")

for i in "${!SERVERS[@]}"; do
    if [[ ${SERVERS[i]} == $(hostname -I | awk '{print $2}') ]]; then
        unset 'SERVERS[i]'
    fi
done

CONTENT="File created by $CURRENT_SERVER on $(date '+%Y-%m-%d %H:%M:%S')"

for SERVER_IP in "${SERVERS[@]}"; do
    FILENAME="${CURRENT_SERVER}_$(date '+%Y-%m-%d_%H:%M:%S').txt"
    echo "$CONTENT" > "/tmp/$FILENAME"
    
    if sftp -o StrictHostKeyChecking=no -o BatchMode=yes vagrant@$SERVER_IP << EOF
        put /tmp/$FILENAME
EOF
    then
        log_message "Successfully created file $FILENAME on $SERVER_IP"
    else
        log_message "Failed to create file $FILENAME on $SERVER_IP"
    fi
    
    rm "/tmp/$FILENAME"
done

log_message "File creation process completed"