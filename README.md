**GREP** is a secure, production-ready DevOps pipeline designed to deploy a **Spring Boot microservice** on **AWS EKS** using **Terraform** and **GitHub Actions**.  
The project demonstrates best practices in **DevOps automation, cloud security, and scalable microservice deployment**.

## Installation Instructions
1. **Run the Installer:**
   - Execute the downloaded installer (e.g., `MyGrepInstaller.exe`).
   - Follow the on-screen instructions to complete the installation.
2. **Usage:**
   - Open a new command prompt.
   - You can now use the `grep` command to search for patterns in files.
## Support and Donations

If you find MyGrepInstaller helpful and would like to support its development, consider making a donation. Your contribution helps maintain and improve the tool.
- **Donate via PayPal:**
  - [Donate](paypal.me/YassineK)

Your support is greatly appreciated!

## Feedback and Issues

For feedback, bug reports, or feature requests, please [open an issue](https://github.com/YASSINEKOO/Grep/tree/master) on GitHub.

Thank you for using MyGrep!

"

---

## 🚀 Architecture

### 🔹 Components
- **Backend**: Spring Boot (Java 21)
- **Containerization**: Docker
- **Orchestration**: AWS EKS (Kubernetes)
- **Infrastructure as Code (IaC)**: Terraform
- **CI/CD**: GitHub Actions → ECR → EKS
- **Database**: Amazon RDS (PostgreSQL)
- **Security & Monitoring**: IAM, Secrets Manager, VPC, CloudWatch, CloudTrail

### 🔹 High-Level Architecture Diagram
```

GitHub Actions
↓
Terraform (IaC)
↓
AWS ECR (Container Registry)
↓
AWS EKS (Kubernetes Cluster)
↓
Spring Boot App (grep)
↓
HTTPS via ALB + ACM
↓
RDS + Secrets Manager + CloudWatch + CloudTrail

````

---

## 🏗️ Deployment Workflow

1. **Infrastructure Provisioning**
   - Terraform creates AWS resources:  
     - VPC, EKS Cluster, Node Groups, RDS, Security Groups  
     - IAM Roles with least-privilege access  

2. **Containerization**
   - Spring Boot app packaged as a Docker image  
   - Exposed on port **8081**  

3. **CI/CD Pipeline**
   - GitHub Actions builds, tags, and pushes Docker image to AWS ECR  
   - Automatically updates deployment on EKS cluster  

4. **Security**
   - Secrets managed via **AWS Secrets Manager** 
   - CloudTrail logs API activities for auditing  
   - Network isolation via **private VPC subnets**

---

## ⚙️ Configuration

| Parameter | Description | Example |
|------------|--------------|----------|
| `APP_NAME` | Application name | `grep` |
| `APP_PORT` | Internal port of the app | `8081` |
| `AWS_REGION` | Deployment region | `eu-west-3` |
| `DOMAIN_NAME` | Domain for HTTPS ingress | `grep.example.com` |

---

## ☸️ Kubernetes Manifests

**Namespace**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: grep
````

**Deployment**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grep-backend
  namespace: grep
spec:
  replicas: 2
  selector:
    matchLabels:
      app: grep
  template:
    metadata:
      labels:
        app: grep
    spec:
      containers:
        - name: grep
          image: <AWS_ACCOUNT_ID>.dkr.ecr.eu-west-3.amazonaws.com/grep:latest
          ports:
            - containerPort: 8081
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: prod
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: grep-db-secret
                  key: password
```

**Service**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: grep-service
  namespace: grep
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 8081
  selector:
    app: grep
```

**Ingress**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grep-ingress
  namespace: grep
  annotations:
    kubernetes.io/ingress.class: alb
spec:
  rules:
    - host: grep.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: grep-service
                port:
                  number: 80
```

---

## 🔁 GitHub Actions CI/CD Workflow

**.github/workflows/ci-cd.yml**

```yaml
name: CI/CD Pipeline - GREP

on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-west-3

      - name: Login to Amazon ECR
        id: ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build Docker image
        run: |
          docker build -t grep:latest ./backend
          docker tag grep:latest ${{ steps.ecr.outputs.registry }}/grep:latest

      - name: Push to Amazon ECR
        run: |
          docker push ${{ steps.ecr.outputs.registry }}/grep:latest

      - name: Update Kubernetes deployment
        run: |
          aws eks update-kubeconfig --region eu-west-3 --name grep-eks-cluster
          kubectl set image deployment/grep-backend grep=${{ steps.ecr.outputs.registry }}/grep:latest -n grep
```

---

## 🔒 Security Highlights

* IAM policies with least-privilege access
* Secrets stored in AWS Secrets Manager (not in GitHub or images)
* Network isolation through VPC subnets and security groups
* CloudTrail and CloudWatch for monitoring and audit logs

---
## 👨‍💻 Author

**Yaaesthetic**
Software & DevOps Engineer
---

### How to Deploy
1. Configure AWS credentials in GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `ECR_REPO`
2. Push code to `main` branch → automatic build & deploy to ECS
