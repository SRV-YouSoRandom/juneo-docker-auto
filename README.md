# JuneoGo Docker Auto Setup

This guide will walk you through setting up the Juneogo Docker container on your **Ubuntu** system. The instructions cover everything from installation to managing your Docker container.

## Table of Contents

1. [Pre-requisites](#pre-requisites)
2. [Installation Steps](#installation-steps)
3. [Creating Backups](#creating-backups)
4. [Accessing Logs](#accessing-logs)
5. [Shutting Down the Container](#shutting-down-the-container)
6. [Restarting the Container](#restarting-the-container)
7. [Downloading Backup Files](#downloading-backup-files)

---

## Pre-requisites

Before proceeding with the installation, ensure that your system has the following prerequisites:

- **Ubuntu-based System**: These instructions are tailored for Ubuntu. If you are using another Linux distribution, the steps may vary slightly.
- **Root/Sudo Privileges**: You will need to have `sudo` privileges to install Docker and make system-level changes.
- **Curl**: If `curl` is not already installed, you can install it using the following command:

```bash
sudo apt-get install curl
```

---

## Installation Steps

1. **Download and Run the Setup Script**

   First, ensure that `curl` is installed. If it's not, follow the steps in the pre-requisites section to install it.

   Then, download and execute the script that sets up Docker and runs the JuneoGo container:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/SRV-YouSoRandom/juneo-docker-auto/main/mainnet.sh | bash
   ```

2. **Follow the Instructions on Screen**

   The script will automatically install Docker, clone the necessary repository, configure Docker, and start the JuneoGo container.

---

## Creating Backups

To create a backup of your staking data, follow these steps:

1. **Create a Backup Directory**:

   Navigate to your home directory and create a new directory called `juneo-staking-backup`:

   ```bash
   mkdir ~/juneo-staking-backup
   ```

2. **Copy Staking Files**:

   Copy the staking files into the newly created backup directory:

   ```bash
   cp -r juneogo-docker/juneogo/.juneogo/staking ~/juneo-staking-backup
   ```

   This will ensure that you have a backup of your staking data in case of any issues.

---

## Accessing Logs

To view the logs of your running JuneoGo container, use the following Docker command:

```bash
docker logs -f juneogo
```

This will display the real-time logs of the JuneoGo container.

---

## Shutting Down the Container

To shut down the running container, you can stop it with this command:

```bash
docker stop juneogo
```

This will stop the container without deleting it. You can restart the container later if needed.

---

## Restarting the Container

To restart the container, use the following command:

```bash
docker restart juneogo
```

This will stop, and then the JuneoGo container will immediately start again.

---

## Downloading Backup Files

If you'd like to download the backup files (`staking` folder) to your local device, you can set up a temporary server to serve the backup folder.

1. **Set Up a Temporary Server**:

   Navigate to the directory containing the backup folder and start a simple HTTP server:

   ```bash
   cd ~/juneo-staking-backup
   python3 -m http.server 8000
   ```

2. **Download the Backup Files**:

   Now, on any device connected to the same network, open a browser and go to the following URL:

   ```
   http://<your-ip>:8000
   ```

   Replace `<your-ip>` with the local IP address of the machine running the server. This will allow you to download the backup files to any device.

3. **Stop the Temporary Server**:

   Once you've finished downloading the files, you can stop the server by pressing `Ctrl + C` in the terminal where the server is running. This will stop the HTTP server and free up the port.

---

That's it! You've successfully set up the JuneoGo Docker container, and you're now ready to manage your container, check logs, create backups, and download them when needed.
