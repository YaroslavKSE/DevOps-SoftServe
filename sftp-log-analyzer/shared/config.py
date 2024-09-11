import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOGS_DIR = os.path.join(BASE_DIR, 'logs')

# Ensure the logs directory exists
os.makedirs(LOGS_DIR, exist_ok=True)

# VM Configuration
VMS = ['192.168.33.14', '192.168.33.15', '192.168.33.16']
SSH_USERNAME = 'sftpuser'
SSH_KEY_PATH = '/app/ssh_key'
REMOTE_LOG_PATH = '/home/sftpuser/sftp_file_creation.log'