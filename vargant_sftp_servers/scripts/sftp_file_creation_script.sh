#!/bin/bash

. /home/$SFTP_USERNAME/.sftp_env

LOG_FILE="/home/$SFTP_USERNAME/sftp_file_creation.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

CURRENT_SERVER=$(hostname)

SERVERS=("$SFTP_IP_1" "$SFTP_IP_2" "$SFTP_IP_3")

for i in "${!SERVERS[@]}"; do
    if [[ ${SERVERS[i]} == $(hostname -I | awk '{print $2}') ]]; then
        unset 'SERVERS[i]'
    fi
done

CONTENT="File created by $CURRENT_SERVER on $(date '+%Y-%m-%d %H:%M:%S')"

for SERVER_IP in "${SERVERS[@]}"; do
    FILENAME="${CURRENT_SERVER}_$(date '+%Y-%m-%d_%H:%M:%S').txt"
    echo "$CONTENT" > "/tmp/$FILENAME"
    
    if sftp -o StrictHostKeyChecking=no -o BatchMode=yes $SFTP_USERNAME@$SERVER_IP << EOF
        put /tmp/$FILENAME /home/$SFTP_USERNAME/sftp/
EOF
    then
        log_message "Successfully created file $FILENAME on $SERVER_IP"
    else
        log_message "Failed to create file $FILENAME on $SERVER_IP"
    fi
    
    rm "/tmp/$FILENAME"
done

log_message "File creation process completed"