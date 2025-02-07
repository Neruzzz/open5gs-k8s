# Open5GS-Kubernetes

## 📌 Project Description
This project is a **follow-up** of my master's thesis, where we are exploring whether deploying **User Plane Functions (UPFs) at the Edge** can be beneficial for **latency-sensitive applications**.

Currently, the network runs with **UERANSIM** as an emulator for the gNB and UEs, but the goal is to migrate to **real hardware** using:
- **Amarisoft** as the gNB
- **Quectel modems and Samsung phones** as UEs

The system already works with **Docker Compose** in an environment where everything is within the same rack, but this project takes it further by deploying it in a **real OVH Cloud** to evaluate performance in a distributed setup.

In the future, the goal is to **automate the network** based on real-time load, traffic, and application needs.

---

## 📂 Project Structure

The project is organized into **two main Helm Charts** within the same repository:

```
Open5GS-KUBERNETES/
│── charts/
│   ├── cloud/       # Core 5G in the Cloud (Open5GS Core)
│   │   ├── templates/
│   │   │   ├── amf-depl.yaml
│   │   │   ├── smf-depl.yaml
│   │   │   ├── upf-depl.yaml
│   │   │   ├── webui-depl.yaml
│   │   │   ├── configmap.yaml
│   │   │   ├── _helpers.tpl
│   │   ├── values.yaml
│   │   ├── Chart.yaml
│   │   ├── README.md
│   ├── edge/        # Edge Deployment (gNB, UE, UPF, SMF)
│   │   ├── templates/
│   │   │   ├── gnb-depl.yaml
│   │   │   ├── ue-depl.yaml
│   │   │   ├── smf-depl.yaml
│   │   │   ├── upf-depl.yaml
│   │   │   ├── configmap.yaml
│   │   ├── values.yaml
│   │   ├── Chart.yaml
│   │   ├── README.md
│── README.md        # This document
│── .gitignore       # Excluded files from repo
```

---

## 🚀 What Does This Project Deploy?

### 🔹 **Cloud (OVH) - charts/cloud/**
- **AMF** (Access and Mobility Management Function)
- **SMF** (Session Management Function)
- **UPF** (User Plane Function)
- **Web UI** for Open5GS
- **MongoDB** for subscriber storage

### 🔹 **Edge (Local Cluster) - charts/edge/**
- **gNB** (UERANSIM, soon Amarisoft)
- **UE** (UERANSIM, soon Quectel modems and Samsung phones)
- **Edge-specific UPF**
- **SMF** to manage sessions at the Edge

Each component is modularized within **separate Helm Charts**, allowing Cloud and Edge to be deployed separately or together.

---

## 🔄 Deployment and Usage

### **1️⃣ Deploy Core in the Cloud**
```sh
helm install open5gs-cloud charts/cloud --namespace open5gs-cloud --create-namespace
```

### **2️⃣ Deploy Edge in Local Cluster**
```sh
helm install open5gs-edge charts/edge --namespace open5gs-edge --create-namespace
```

### **3️⃣ Deploy Both (Cloud + Edge)**
```sh
helm install open5gs charts/ --set cloud.enabled=true --set edge.enabled=true
```

---

## 📌 Current Status and Next Steps
✅ **Current Status:**
- The network **works with UERANSIM**, allowing real traffic testing between the Core in OVH and a local Edge cluster.
- Cloud and Edge deployments are **separated**, ensuring modularity and scalability.

🚀 **Next Steps:**
- **Migration to Amarisoft** to use a real gNB.
- **Integration with Quectel modems and Samsung phones** as real UEs.
- **Optimization of traffic at the Edge UPF** to see if it improves latency-sensitive applications.
- **Automating the network** to dynamically manage resources based on load.

---

## 📄 References
- [Open5GS](https://open5gs.org/)
- [UERANSIM](https://github.com/aligungr/UERANSIM)
- [Helm](https://helm.sh/)

If you have any questions or suggestions, feel free to open an issue or reach out! 🚀

