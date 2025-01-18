# Jenkins on Kubernetes Setup

This repository contains Kubernetes YAML files for deploying Jenkins with MetalLB, Ingress, and persistent storage on a Kubernetes cluster. It sets up Jenkins with the following components:

- **Jenkins Deployment**
- **Persistent Storage using PersistentVolume (PV) and PersistentVolumeClaim (PVC)**
- **Ingress with NGINX Ingress Controller**
- **MetalLB for Load Balancer IP management**

## Prerequisites

- A running Kubernetes cluster
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) command-line tool configured
- [Helm](https://helm.sh/docs/intro/install/) for deploying NGINX Ingress (optional)
- [MetalLB](https://metallb.universe.tf/) deployed for LoadBalancer functionality

## Setup

### 1. Namespace Creation
The `jenkins` namespace is created for Jenkins resources. This is defined in `jenkins-ingress.yaml`.

### 2. Persistent Storage

The setup uses persistent storage with **PersistentVolume (PV)** and **PersistentVolumeClaim (PVC)**.

```bash
kubectl apply -f jenkins/
```
