import paramiko
import logging
from getpass import getpass

def connect_ssh(hostname, username, key_filename):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(hostname, username=username, key_filename=key_filename)
        return client
    except paramiko.ssh_exception.AuthenticationException:
        passphrase = getpass(f"Enter passphrase for key '{key_filename}': ")
        try:
            key = paramiko.RSAKey.from_private_key_file(key_filename, password=passphrase)
            client.connect(hostname, username=username, pkey=key)
            return client
        except Exception as e:
            logging.error(f"Failed to connect to {hostname} with passphrase: {str(e)}")
            return None
    except Exception as e:
        logging.error(f"Failed to connect to {hostname}: {str(e)}")
        return None

def download_log(ssh_client, remote_path, local_path):
    sftp = ssh_client.open_sftp()
    try:
        sftp.get(remote_path, local_path)
        logging.info(f"Successfully downloaded {remote_path} to {local_path}")
    except Exception as e:
        logging.error(f"Failed to download {remote_path}: {str(e)}")
    finally:
        sftp.close()
