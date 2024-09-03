# SFTP Server Setup and Log Analysis Runbook

## Prerequisites
- Vagrant installed on the system
- VirtualBox installed on the system
- 4 GB of RAM available
- 4 CPUs available
- Git installed (for cloning the repository)

## Setup Steps

### 1. Clone the Repository
```bash
git clone <repository_url>
cd <cloned_repository_folder>
```

### 2. Create Environment File
Create a `.env` file in the root of the cloned repository with the following content:
```
SFTP_USERNAME=sftpuser
SFTP_PASSWORD=sftppassword
SFTP_IP_1=192.168.33.14
SFTP_IP_2=192.168.33.15
SFTP_IP_3=192.168.33.16
```

### 3. Start the Virtual Machines
```bash
vagrant up
```

### 4. Initial Setup and User Creation
```bash
vagrant provision --provision-with initial_setup,create_sftp_user,generate_ssh_key
```

### 5. Exchange SSH Keys and Setup SFTP
```bash
vagrant provision --provision-with exchange_keys,setup_sftp
```

### 6. Add Local SSH Key
- Copy your public SSH key to the root project folder and name it `local_id_rsa.pub`.
- Run the following command:
  ```bash
  vagrant provision --provision-with add_local_key
  ```
- After provisioning, you can delete the `local_id_rsa.pub` file from the project folder.

### 7. Disable Password Authentication
```bash
vagrant provision --provision-with disable_password_auth
```

## Using the Log Analyzer

### 1. Navigate to the Project Root Directory
```bash
cd /path/to/your/project
```

### 2. Install Required Python Packages
```bash
pip install -r requirements.txt
```

### 3. Download Logs and Generate Report
Replace `<path_to_your_private_key>` with the actual path to your SSH private key.
```bash
python download_and_generate_report.py --vms 192.168.33.14 192.168.33.15 192.168.33.16 --username sftpuser --key_filename "<path_to_your_private_key>" --remote_log_path /home/sftpuser/sftp_file_creation.log
```

This command will:
- Download log files from the specified VMs
- Parse the logs
- Generate a text report (default filename: `sftp_log_report.txt`)

### 4. View the Generated Report
You can open the generated report file (default: `sftp_log_report.txt`) to view the analysis results.

### 5. Run the Flask Web Application
To view the report in a web interface:

```bash
python run_webapp.py
```

This will start the Flask development server. By default, it runs on `http://127.0.0.1:5000/`.

### 6. Access the Web Interface
Open a web browser and navigate to `http://127.0.0.1:5000/` to view the SFTP Log Analysis Report in a user-friendly interface.

Note: The Flask application reads the log files from the `logs` directory in your project root. Make sure you've run the `download_and_generate_report.py` script before starting the web application to ensure the most up-to-date data is displayed.

### 7. Stopping the Web Application
To stop the Flask application, press `CTRL+C` in the terminal where it's running.

Remember to run the `download_and_generate_report.py` script periodically or set up a cron job to keep your log data up-to-date.

## Additional Notes
- Ensure that your SSH private key has the correct permissions (typically 600 or 400).
- The log analyzer will generate a report in the current directory named `sftp_log_report.txt` by default.
- If you encounter any issues with SSH key authentication, you may be prompted for the passphrase of your SSH key.

## Troubleshooting
- If you encounter any network-related issues, ensure that the IP addresses specified in the `.env` file don't conflict with your local network.
- In case of SSH connection problems, verify that the SFTP user was created successfully and that the SSH keys were exchanged correctly.
- For any Vagrant-related issues, consult the Vagrant documentation or try running `vagrant status` to check the state of the virtual machines.