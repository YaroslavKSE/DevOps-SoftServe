import paramiko
import re
from collections import defaultdict
import argparse
import logging
from pathlib import Path
from getpass import getpass

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def connect_ssh(hostname, username, key_filename):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        # First, try to connect without a passphrase
        client.connect(hostname, username=username, key_filename=key_filename)
        return client
    except paramiko.ssh_exception.AuthenticationException:
        # If a passphrase is required, prompt the user
        passphrase = getpass("Enter passphrase for key '{}': ".format(key_filename))
        try:
            # Try to connect again with the passphrase
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

def parse_log(log_path):
    ip_count = defaultdict(int)
    fail_count = defaultdict(int)
    fail_messages = []
    success_pattern = r"Successfully created file .+ on (\d+\.\d+\.\d+\.\d+)"
    fail_pattern = r"Failed to create file (.+) on (\d+\.\d+\.\d+\.\d+)"

    with open(log_path, 'r') as file:
        for line in file:
            success_match = re.search(success_pattern, line)
            fail_match = re.search(fail_pattern, line)
            
            if success_match:
                ip = success_match.group(1)
                ip_count[ip] += 1
            elif fail_match:
                filename = fail_match.group(1)
                server_ip = fail_match.group(2)
                fail_count[server_ip] += 1
                fail_messages.append(f"Failed to create file {filename} on {server_ip}")

    return ip_count, fail_count, fail_messages

def generate_report(ip_counts, fail_counts, fail_messages):
    report = "SFTP Log Analysis Report\n"
    report += "========================\n\n"
    
    report += "Successfully Created Records:\n"
    for ip, count in ip_counts.items():
        report += f"Records created on Server IP {ip}: {count}\n"
    report += "\n"
    
    report += "Failed Reports:\n"
    if sum(fail_counts.values()) == 0:
        report += "Failed reports: 0\n"
    else:
        for ip, count in fail_counts.items():
            report += f"Failed to create reports on server IP {ip}: {count}\n"
        report += "\nDetailed Failure Messages:\n"
        for message in fail_messages:
            report += f"{message}\n"

    return report

def main(vms, username, key_filename, remote_log_path, output_file):
    all_ip_counts = defaultdict(int)
    all_fail_counts = defaultdict(int)
    all_fail_messages = []

    for vm in vms:
        ssh_client = connect_ssh(vm, username, key_filename)
        if ssh_client:
            local_log_path = f"{vm}_sftp_file_creation.log"
            download_log(ssh_client, remote_log_path, local_log_path)
            ssh_client.close()

            ip_counts, fail_counts, fail_messages = parse_log(local_log_path)
            for ip, count in ip_counts.items():
                all_ip_counts[ip] += count
            for ip, count in fail_counts.items():
                all_fail_counts[ip] += count
            all_fail_messages.extend(fail_messages)

    report = generate_report(all_ip_counts, all_fail_counts, all_fail_messages)
    
    with open(output_file, 'w') as f:
        f.write(report)
    logging.info(f"Report generated and saved to {output_file}")
    print(report)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="SFTP Log Analyzer")
    parser.add_argument("--vms", nargs="+", required=True, help="List of VM IP addresses")
    parser.add_argument("--username", required=True, help="SSH username")
    parser.add_argument("--key_filename", required=True, help="Path to SSH private key")
    parser.add_argument("--remote_log_path", required=True, help="Path to the log file on remote VMs")
    parser.add_argument("--output_file", default="sftp_log_report.txt", help="Output file for the report")
    
    args = parser.parse_args()
    
    main(args.vms, args.username, args.key_filename, args.remote_log_path, args.output_file)