## Web Application Deployment Runbook for Linux Ubuntu 24.04

This runbook provides detailed instructions to deploy a web application using Docker and Docker Compose on a Linux Ubuntu 24.04 environment. Additionally, it guides you through restoring the database after the application is started.

### Prerequisites

Before you start, ensure you have the following:

1. **Linux Ubuntu 24.04** installed and running.
2. **Access to the application’s Git repository**.
3. **Docker** and **Docker Compose** installed on your machine.
4. **10 GB** of disk space
5. **4 GB** of RAM
6. **2 CPUs** 

### Step 1: Clone the Repository

First, clone the repository that contains the application code:

```bash
git clone <repository_url>
cd <repository_directory>
```

Replace `<repository_url>` with the actual URL of your Git repository and `<repository_directory>` with the directory name where the repository will be cloned.

### Step 2: Install Docker and Docker Compose

If Docker and Docker Compose are not installed on your system, follow these steps to install them:

#### 2.1 Install Docker

1. Update your package index:

    ```bash
    sudo apt-get update
    ```

2. Install Docker's package dependencies:

    ```bash
    sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
    ```

3. Add Docker’s official GPG key:

    ```bash
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    ```

4. Add Docker’s official APT repository:

    ```bash
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    ```

5. Install Docker:

    ```bash
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    ```

6. Verify the Docker installation:

    ```bash
    docker --version
    ```

#### 2.2 Install Docker Compose

1. Download the Docker Compose binary:

    ```bash
   sudo apt-get install docker-compose-plugin
    ```

2. Verify the Docker Compose installation:

    ```bash
    docker compose --version
    ```

### Step 3: Create the `.env` File

In the root of your project directory, create a `.env` file with the following content:

```env
POSTGRES_DB=schedule_database
POSTGRES_USER=schedule_user
POSTGRES_PASSWORD=schedule_password
DATABASE_URL=jdbc:postgresql://postgres:5432/schedule_database
REDIS_PROTOCOL=redis
REDIS_HOST=redis
REDIS_PORT=6379
REACT_APP_API_BASE_URL=http://localhost:8080
MONGO_CURRENT_DATABASE=schedules
DEFAULT_SERVER_CLUSTER=mongo
```

Ensure that this file is saved in the root directory of your project.

### Step 4: Start the Application

With the `.env` file in place, you can now start the application using Docker Compose:

```bash
docker-compose up -d
```

This command will pull the necessary Docker images (if not already available) and start the containers as defined in your `docker-compose.yml` file. The `-d` flag runs the containers in the background.

### Step 5: Access the Application

After the containers have started successfully, the application should be accessible at:

```url
http://localhost:3000
```

Open your web browser and navigate to this URL to confirm that the application is running.

### Step 6: Restore the Database

If you need to restore the database, follow these steps:

#### 6.1 Set Environment Variables

Before running the database restore script, ensure the necessary environment variables are set in your terminal:

```bash
export DB_NAME="schedule_database"
export DB_USER="schedule_user"
export DB_PASSWORD="schedule_password"
```

#### 6.2 Run the Restore Script
1. Give run permission for the scripts
    ```bash
    chmod +x scripts/restore_database.sh
    ```
2. To restore the database, run the `restore_db.sh` script with the required arguments:

   ```bash
   ./scripts/restore_db.sh <db_container_name> <dump_file_path>
   ```

- `<db_container_name>`: The name of the database container as defined in your `docker-compose.yml`.
- `<dump_file_path>`: The path to the database dump file you wish to restore.

### Step 7: Verify the Database Restoration

After the script completes, verify that the database has been restored successfully by visiting http://localhost:3000
again. On this step the schedule should be visible.


### Step 8: Managing the Application

- **To stop the application**, use:

  ```bash
  docker-compose down
  ```

- **To view logs**, use:

  ```bash
  docker-compose logs -f
  ```

## Configure Nginx as a reverse proxy (Optional)
### Step 1: Install Nginx

First, install Nginx on your Linux machine if it is not already installed.

1. Update your package index:

   ```bash
   sudo apt-get update
   ```

2. Install Nginx:

   ```bash
   sudo apt-get install nginx
   ```

3. Once installed, start the Nginx service:

   ```bash
   sudo systemctl start nginx
   ```

4. Enable Nginx to start at boot:

   ```bash
   sudo systemctl enable nginx
   ```

5. Verify that Nginx is running:

   ```bash
   sudo systemctl status nginx
   ```

### Step 2: Configure Nginx as a Reverse Proxy

Now that Nginx is installed, you can configure it to act as a reverse proxy for your web application.

1. **Navigate to the Nginx configuration directory:**

   ```bash
   cd /etc/nginx/sites-available/
   ```

2. **Create a new configuration file for your application:**

   Let's assume your web application is running on `http://localhost:3000`. Create a configuration file named `scheduleapp`:

   ```bash
   sudo nano /etc/nginx/sites-available/scheduleapp
   ```

3. **Add the following configuration to the file:**

   ```nginx
   server {
       listen 80;
       server_name localhost;
   
       location / {
           proxy_pass http://localhost:3000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   
       location /api {
           proxy_pass http://localhost:8080;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

4. **Enable the configuration by creating a symbolic link to `sites-enabled`:**

   ```bash
   sudo ln -s /etc/nginx/sites-available/scheduleapp /etc/nginx/sites-enabled/
   ```

5. **Disable the Default Configuration**
   ```bash
   sudo rm /etc/nginx/sites-enabled/default
   ```

6. **Test the Nginx configuration for syntax errors:**

   ```bash
   sudo nginx -t
   ```

   If the test is successful, you will see a message like:

   ```
   nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
   nginx: configuration file /etc/nginx/nginx.conf test is successful
   ```

7. **Reload Nginx to apply the changes:**

   ```bash
   sudo systemctl reload nginx
   ```

### Step 3: Test the Configuration

1. Open a web browser on your local machine and go to `http://localhost` or write 
   ```bash 
   curl http://localhost
   ```

2. You should see your web application, which indicates that Nginx is successfully acting as a reverse proxy, forwarding requests to `http://localhost:3000`.



### Conclusion

Following these steps, you should have your web application running on Ubuntu 24.04 with Docker and Docker Compose, 
Nginx working as a reverse proxy, and the database restored from a backup. If you encounter any issues, refer to the Docker and Docker Compose documentation or check the logs for troubleshooting.
