import logging
from .ssh_utils import connect_ssh, download_log
from shared.config import LOGS_DIR, VMS, SSH_USERNAME, SSH_KEY_PATH, REMOTE_LOG_PATH
import os

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def main():
    for vm in VMS:
        ssh_client = connect_ssh(vm, SSH_USERNAME, SSH_KEY_PATH)
        if ssh_client:
            local_log_path = os.path.join(LOGS_DIR, f"{vm}_sftp_file_creation.log")
            download_log(ssh_client, REMOTE_LOG_PATH, local_log_path)
            ssh_client.close()

    logging.info("Log download completed")

if __name__ == "__main__":
    main()