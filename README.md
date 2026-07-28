# SubiCloud Server

SubiCloud Server is a self-hosted server platform built using Docker.

## Goals

- Raspberry Pi compatible
- SSD for OS and applications
- HDD for customer data
- Git as the source of truth
- One Docker Compose project per application
- Simple deployment
- Easy backup and restore

## Current Status

- Ubuntu Server
- Docker
- SSH

Below is the initial setup required

Install ubuntu server 26.04

## Ubuntu Setup
### Update to latest
```
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudsubi $@bari
o reboot
```

### Verification
```
hostname
ip addr show enp7s0
lsb_release -a
df -h
```

### Add SSH-keygen to admin system (service access)
```
ssh-keygen -f ~/.ssh/known_hosts -R <ipaddress>
```
example
```
ssh-keygen -f ~/.ssh/known_hosts -R 192.168.2.99
```

## Docker
### 1\. Remove any old Docker packages

```
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  sudo apt remove -y $pkg
done
```

### 2\. Install prerequisites

```
sudo apt update
sudo apt install -y ca-certificates curl
```

### 3\. Create the keyring directory

```
sudo install -m 0755 -d /etc/apt/keyrings
```

### 4\. Download Docker's GPG key

```
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

### 5\. Add the Docker repository

```
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 6\. Install Docker

```
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 7\. Allow your user to run Docker without `sudo`

```
sudo usermod -aG docker $USER
```

Then either **log out and log back in**, or simply reboot:

`sudo reboot`

### 8\. Verify

```
docker --version
docker compose version
docker run hello-world
```

You should see the "Hello from Docker!" message.
