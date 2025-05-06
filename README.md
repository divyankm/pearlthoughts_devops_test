# 🚀 Yii2 + Docker Swarm + CI/CD + Ansible Deployment

This repository provides an automated DevOps pipeline to deploy a Yii2 PHP application using Docker Swarm on an AWS EC2 instance. It includes infrastructure automation with Ansible, a CI/CD workflow via GitHub Actions, and NGINX as a reverse proxy running directly on the host.

---

## 📦 Project Structure

.
├── ansible/
│   ├── install_docker.yml
│   ├── setup_nginx.yml
│   ├── deploy_app.yml
│   └── ...
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── nginx/
│   └── default.conf
├── .github/
│   └── workflows/
│       └── deploy.yml
├── src/                  # Yii2 application (optional if cloning)
├── README.md
└── ...

🛠 Tech Stack
PHP Yii2 Framework

Docker + Docker Swarm

NGINX (Host-based reverse proxy)

Ansible for infrastructure automation

GitHub Actions for CI/CD

📋 Setup Instructions
1. Prerequisites
AWS EC2 instance (Ubuntu 20.04+ recommended)

Domain name (for NGINX reverse proxy)

GitHub repo connected to your EC2 with SSH access

Docker Hub or GitHub Container Registry account

2. Clone This Repo

git clone https://github.com/your-username/yii2-docker-swarm-deploy.git
cd yii2-docker-swarm-deploy

3. Ansible Setup & Deployment
Update the inventory file with your EC2 IP.

Run Ansible playbooks:


ansible-playbook -i inventory ansible/install_docker.yml
ansible-playbook -i inventory ansible/setup_nginx.yml
ansible-playbook -i inventory ansible/deploy_app.yml

4. GitHub Actions CI/CD
Triggered on push to main.

Workflow (.github/workflows/deploy.yml) will:

Build and push Docker image

SSH into EC2

Pull the new image

Update Docker Swarm service

GitHub Secrets Required:

Name	Description
EC2_SSH_KEY	SSH private key (base64-encoded)
EC2_HOST	EC2 instance public IP or DNS
EC2_USER	SSH username (ubuntu, etc.)
DOCKER_USERNAME	Docker Hub username
DOCKER_PASSWORD	Docker Hub password/token

5. NGINX Configuration
Reverse proxy setup in nginx/default.conf, routes traffic to the Yii2 app container on a specific port.

✅ How to Test
Visit your domain or EC2 IP in the browser.

Yii2 application should be accessible via HTTP.

Logs: Use docker service logs <service-name> for debugging.

🎯 Bonus Features
 GitHub Secrets used for sensitive data

 Docker health checks defined

 Optional: Prometheus + Node Exporter for monitoring

📌 Assumptions
Only a single-node Swarm setup (for simplicity)

The Yii2 application is either pre-cloned or part of this repo

The domain is already pointed to the EC2 public IP# pearlthoughts_devops_test
PearlThoughts| DevOpsEngineer 
