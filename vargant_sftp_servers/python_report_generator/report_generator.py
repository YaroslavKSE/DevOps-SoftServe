def generate_text_report(server_records, fail_counts, fail_messages):
    report = "SFTP Log Analysis Report\n"
    report += "========================\n\n"
    
    report += "Successfully Created Records by Server:\n"
    for server_ip, sources in server_records.items():
        report += f"Server IP {server_ip}:\n"
        for source, count in sources.items():
            report += f"  - From sftp{source}: {count}\n"
        report += f"  Total: {sum(sources.values())}\n\n"
    
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