import re
from collections import defaultdict
import os

def parse_logs(logs_dir):
    server_records = defaultdict(lambda: defaultdict(int))
    fail_count = defaultdict(int)
    fail_messages = []
    success_pattern = r"Successfully created file (.+) on (\d+\.\d+\.\d+\.\d+)"
    fail_pattern = r"Failed to create file (.+) on (\d+\.\d+\.\d+\.\d+)"

    for filename in os.listdir(logs_dir):
        if filename.endswith('_sftp_file_creation.log'):
            with open(os.path.join(logs_dir, filename), 'r') as file:
                for line in file:
                    success_match = re.search(success_pattern, line)
                    fail_match = re.search(fail_pattern, line)
                    
                    if success_match:
                        file_name, server_ip = success_match.groups()
                        source_server = file_name.split('_')[0].replace('sftp', '')
                        server_records[server_ip][source_server] += 1
                    elif fail_match:
                        filename, server_ip = fail_match.groups()
                        fail_count[server_ip] += 1
                        fail_messages.append(f"Failed to create file {filename} on {server_ip}")

    return server_records, fail_count, fail_messages