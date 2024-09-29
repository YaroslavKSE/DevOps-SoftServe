## Database setup

### PostgreSQL Setup
```sh
sudo apt update && sudo apt upgrade -y
wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee  /etc/apt/sources.list.d/pgdg.list
sudo apt update
sudo apt install -y postgresql-13
```

### Configure PostgreSQL
```sh
sudo -i -u postgres

psql
CREATE DATABASE schedule_database;
CREATE USER schedule_user WITH PASSWORD 'schedule_password';
GRANT ALL PRIVILEGES ON DATABASE schedule_database TO schedule_user;
\q

```

### Step 4: Configure Remote Access 
By default, PostgreSQL listens on localhost. To allow connections from the backend instance:

Edit postgresql.conf:

```sh
sudo nano /etc/postgresql/13/main/postgresql.conf
```
Set listen_addresses:

```sh
listen_addresses = '*'
```
Edit pg_hba.conf:

```sh
sudo nano /etc/postgresql/13/main/pg_hba.conf
```
Add the following line at the end:
```sh
host    all             all             <backend_private_ip>/32        md5
```
Replace <backend_private_ip> with the private IP of your backend instance.

### Restore database
1. Edit PostgreSQL's pg_hba.conf file:
```sh
sudo nano /etc/postgresql/13/main/pg_hba.conf
```
2. Change peer to md5
```sh
# Database administrative login by Unix domain socket
local   all             postgres                                md5
# "local" is for Unix domain socket connections only
local   all             all                                     md5
```
3. Before running the database restore script, ensure the necessary environment variables are set in your terminal:

```sh
export DB_NAME="schedule_database"
export DB_USER="schedule_user"
export DB_PASSWORD="schedule_password"
```

4. Give run permission for the scripts

```sh
chmod +x scripts/restore_database.sh
```

5. Run the script to restore database
```sh
./restore_script.sh local "" /path/to/database.dump
```

### MongoDB Setup

1. Install Dependencies
```sh
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
```
2. Import the MongoDB Public GPG Key
```sh
sudo apt-get install gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
```
3. Create the MongoDB Repository List:
```sh
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Install MongoDB
sudo apt-get update
sudo apt-get install -y mongodb-org

# Enable MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

```

4. Verify MongoDB Installation
```sh
sudo systemctl status mongod
```

5. Configure Remote Access
```sh
sudo nano /etc/mongod.conf
```
```
net:
  port: 27017
  bindIp: 0.0.0.0
```

### Redis Setup:

Add the Redis repository
```sh
sudo add-apt-repository ppa:redislabs/redis -y
sudo apt update
sudo apt install -y redis-server
```
Verify the Redis version
```sh
redis-server --version
```

Step 2: Configure Redis
```sh
sudo nano /etc/redis/redis.conf
```
Bind to all IP addresses:
```sh
bind 0.0.0.0
```

## Backend Setup

### Java 11 installation

```sh
sudo apt update && sudo apt upgrade -y

sudo apt install -y openjdk-11-jdk

java -version
# Should output version 11.x
```

### Install Gradle 7.2

```sh
wget https://services.gradle.org/distributions/gradle-7.2-bin.zip

sudo mkdir /opt/gradle
sudo unzip -d /opt/gradle gradle-7.2-bin.zip

echo 'export PATH=$PATH:/opt/gradle/gradle-7.2/bin' >> ~/.profile
source ~/.profile

gradle -v
# Should output version 7.2
```

### Build the Application

```sh
cd <project-directory>

gradle build -x test --no-daemon
```


### Install Tomcat 9.0.50
```sh
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.50/bin/apache-tomcat-9.0.50.tar.gz

sudo mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-9.0.50.tar.gz -C /opt/tomcat --strip-components=1

sudo rm -rf /opt/tomcat/webapps/*

sudo cp build/libs/*.war /opt/tomcat/webapps/ROOT.war

sudo chown -R ubuntu:ubuntu /opt/tomcat

sudo chmod +x /opt/tomcat/bin/*.sh

```

### Configure Environment Variables

```sh
sudo nano /opt/tomcat/bin/setenv.sh

export POSTGRES_DB=schedule_database
export POSTGRES_USER=schedule_user
export POSTGRES_PASSWORD=schedule_password
export DATABASE_URL=jdbc:postgresql://<postgres_private_ip>:5432/schedule_database
export REDIS_PROTOCOL=redis
export REDIS_HOST=<redis_private_ip>
export REDIS_PORT=6379
export MONGO_CURRENT_DATABASE=schedules
export DEFAULT_SERVER_CLUSTER=<mongo_private_ip>
```

### Start Tomcat
```sh
/opt/tomcat/bin/startup.sh
```


## Frontend Setup

1. Update packages
```sh
sudo apt update && sudo apt upgrade -y
```

2. Install Node.js 18

```sh
# Install curl if not installed
sudo apt install -y curl

# Add NodeSource PPA
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Install Node.js
sudo apt install -y nodejs

# Verify Node.js and npm versions
node -v  # Should output v14.17.4 or similar 14.x version
npm -v
```

3. Navigate to Frontend Application

cd <frontend_repo_directory>

4.  Install Dependencies
```sh
npm install
```

5. Configure Environment Variables
Set the environment variable REACT_APP_API_BASE_URL.
```sh
echo 'export REACT_APP_API_BASE_URL=http://<backend_private_ip>:8080' >> ~/.profile
source ~/.profile
```
Alternatively, you can create a .env file in your project directory:
```sh
echo 'REACT_APP_API_BASE_URL=http://<backend_private_ip>:8080' > .env
```

6. Build and Run the Application
```sh
npm start
```
