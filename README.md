# 🌌 Open5GS-K8s Helm Chart

This project provides a Helm-based deployment for **Open5GS** in Kubernetes, targeting a distributed architecture with **Cloud** and **Edge** clusters.

Currently, only the **Cloud deployment** has been functionally tested. Multi-cluster communication has **not yet been validated**, but the project is designed with this future capability in mind.

> ℹ️ By default, a simulated gNB (UERANSIM) is also deployed in the cloud. You can **disable it** in `values.yaml` if you only want to run the 5G Core.

---

## 📂 Project Structure

* `charts/cloud/` and `charts/edge/`:

  * Contains Helm charts for deploying Open5GS components to the **cloud** and **edge** respectively.
  * Inside each chart:

    * `templates/`: All YAML Kubernetes manifests.

      * Files ending in `-cmap.yaml` are **ConfigMaps** containing configuration for each Open5GS service.
      * Files ending in `-depl.yaml` are **Deployment manifests** to launch services as Kubernetes pods.

* `images/`:

  * Dockerfiles for building container images:

    * `open5gs/`: Base Open5GS network functions (AMF, SMF, etc.).
    * `ueransim/`: Simulated gNB and UE.
    * `webui/`: Open5GS Web UI.

* `Makefile`:

  * Automates building and pushing images to a container registry.

---

## 💡 Open5GS Components Overview

| Component | Role                                                 |
| --------- | ---------------------------------------------------- |
| AMF       | Manages UE registration and control plane signaling. |
| SMF       | Handles session setup and routes data via UPF.       |
| UPF       | Responsible for forwarding user data packets.        |
| AUSF      | Performs authentication with UDM.                    |
| UDM       | Stores and manages subscriber data.                  |
| UDR       | Backend data storage for UDM.                        |
| NSSF      | Decides which network slice to use.                  |
| NRF       | Acts as service discovery for network functions.     |
| BSF       | Authenticates devices and exposes credentials.       |
| PCF       | Manages policy rules for subscribers and flows.      |

**Extra Components:**

* `webui`: A graphical interface to register UEs (subscribers) into the system.
* `ueransim`: A simulator for User Equipment (UE) and gNB to emulate end-to-end 5G traffic and registration flows.

---

## 🔧 Build and Push Docker Images

To build and push Docker images, use the provided `Makefile`.

Edit the `PREFIX` variable to match your container registry:

```makefile
PREFIX = registry.gitlab.bsc.es/ppc/software/open5gs-k8s
```

Then run:

```bash
make
```

This will build and push:

* `open5gs` image tagged with Open5GS version (default: 2.6.6)
* `webui` image tagged as `latest`
* `ueransim` image tagged with version (default: 3.2.6)

> 💡 You may also use `make no-cache` if you want to rebuild everything from scratch.

---

## 🚀 Deploying with Helm

### 1. Install Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

### 2. Access Your Kubernetes Cluster

Make sure you have the correct kubeconfig set:

```bash
kubectl config use-context <your-cluster>
```

### 3. Deploy Open5GS (Cloud)

```bash
cd charts/cloud
helm install open5gs .
```

Once deployed, you can verify everything is running:

```bash
kubectl get pods
```

Expected output:

```
NAME                            READY   STATUS    RESTARTS   AGE
amf-depl-5589bdbb9c-npwv8       1/1     Running   0          90s
ausf-depl-6cb995dcc6-tpds2      1/1     Running   0          90s
bsf-depl-5c4f59878f-88kws       1/1     Running   0          90s
gnb-depl-59d9748c6-txk7j        1/1     Running   0          90s
nrf-depl-75457b574d-xprvp       1/1     Running   0          89s
nssf-depl-79b45f998b-7vpj4      1/1     Running   0          90s
open5gs-mongodb-0               1/1     Running   0          90s
open5gs-webui-56db4959d-nqxfx   1/1     Running   0          90s
pcf-depl-b78947879-g4drm        1/1     Running   2          90s
smf-depl-65ccb87db7-5j6hd       1/1     Running   0          90s
udm-depl-74bc7b64f6-bc9lm       1/1     Running   0          90s
udr-depl-65c887645c-xh5b7       1/1     Running   1          90s
ue-depl-667df78666-7kzrp        1/1     Running   0          90s
upf-depl-cbd96f675-dl6l9        1/1     Running   0          90s
```

You can check logs of any pod. For example:

```bash
kubectl logs amf-depl-5589bdbb9c-npwv8
```

Example showing gNB connection to AMF:

```
[amf] INFO: gNB-N2 accepted[192.168.58.122]:51170 in ng-path module
[amf] INFO: [Added] Number of gNBs is now 1
```

---

## 🔖 License

This project is licensed under the MIT License. See the [`LICENSE`](LICENSE) file for details.
