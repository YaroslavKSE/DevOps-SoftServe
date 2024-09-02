import argparse
import logging
from python_report_generator.ssh_utils import connect_ssh, download_log
from python_report_generator.log_parser import parse_logs
from python_report_generator.report_generator import generate_text_report
from config import LOGS_DIR
import os

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def main(vms, username, key_filename, remote_log_path, output_file):
    for vm in vms:
        ssh_client = connect_ssh(vm, username, key_filename)
        if ssh_client:
            local_log_path = os.path.join(LOGS_DIR, f"{vm}_sftp_file_creation.log")
            download_log(ssh_client, remote_log_path, local_log_path)
            ssh_client.close()

    ip_counts, fail_counts, fail_messages = parse_logs(LOGS_DIR)
    report = generate_text_report(ip_counts, fail_counts, fail_messages)
    
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