# 🚀 OpenShift Full DevOps Orchestration Guide

This document outlines the transition from local-binary builds to a production-grade **Full DevOps Lifecycle** using Git, Jenkins, SonarQube, and Docker.

---

## 🛠️ Your Action Items (Manual Setup)

Since the pipeline is now fully automated, you need to configure the external tools to "talk" to Jenkins. Please perform these steps on your Jenkins and OpenShift instances:

### 1. Jenkins Credentials
Go to **Manage Jenkins > Credentials > System > Global credentials**. Add the following:

| ID | Type | Description |
| :--- | :--- | :--- |
| `oc-token` | Secret Text | Your OpenShift API Token (Get it from `oc whoami -t`) |
| `docker-hub-login` | Username with password | Your Docker Registry (Docker Hub/Quay) credentials. |
| `sonar-token` | Secret Text | Analysis token generated from SonarQube |

### 2. SonarQube Configuration
- **On SonarQube**: Create a new project named `signaling-server`.
- **On Jenkins**: Install the "SonarQube Scanner" plugin. 
- Go to **Manage Jenkins > System**. Add your SonarQube Server URL (default: `http://localhost:9000`).

### 3. OpenShift Image Pull Secret
If you are using a private registry (like Docker Hub), OpenShift needs permission to pull the image:
```bash
oc create secret docker-registry regsecret \
    --docker-server=https://index.docker.io/v1/ \
    --docker-username=<your-name> \
    --docker-password=<your-pws> \
    --docker-email=<your-email>

oc secrets link default regsecret --for=pull
```

---

## 🔄 The New DevOps Flow

1.  **Commit**: You push code to GitHub.
2.  **Analyze**: Jenkins triggers and runs **SonarQube** to check for bugs/vulnerabilities.
3.  **Build**: Jenkins builds a **Docker Image** using the `Dockerfile` in `signaling_server/`.
4.  **Registry**: Jenkins pushes that image to your Registry (Docker Hub).
5.  **Deploy**: Jenkins tells **OpenShift** to update the deployment to the new image.
6.  **Rollout**: OpenShift performs a zero-downtime rolling update.

---

## 🖥️ Useful Commands for You

**Monitor the Rollout:**
```bash
oc rollout status deployment/signaling-server
```

**Check Service Logs:**
```bash
oc logs -f deployment/signaling-server
```

**Verify the Public URL:**
```bash
oc get route signaling-server
```

> [!NOTE]
> If you change your Docker Hub username, update the `DOCKER_IMAGE` variable at the top of the **[Jenkinsfile](file:///c:/project%20space/alumini_screen/Jenkinsfile)**.
