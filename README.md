# 🌌 Open5GS-K8s Helm Chart

This project provides a Helm-based deployment for **Open5GS** in Kubernetes, targeting a distributed architecture with **Cloud** and **Edge** clusters.

Currently, only the **Cloud deployment** has been functionally tested. Multi-cluster communication has **not yet been validated**, but the project is designed with this future capability in mind.

> ℹ️ By default, a simulated gNB (UERANSIM) is also deployed in the cloud. You can **disable it** in `values.yaml` if you only want to run the 5G Core.


## 📂 Project structure

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



## 💡 Open5GS components overview

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



## 🔧 Build and push Docker images

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

## ⚙️ Configuration (values.yaml)

This section provides a detailed explanation of the configurable parameters available in the `values.yaml` file, focusing on the **cloud deployment**.


### 🔧 Global parameters (`global_config`)

```yaml
global_config:
  sbi:
    advertise: false     # Whether to advertise SBI interfaces via NRF (Service-Based Interface registry)
  host:
    interface: ens16     # Network interface used for the UPF GTP-U traffic (must match actual NIC name)
  db_uri: mongodb://mongodb-svc:27017/open5gs  # URI used by Open5GS to connect to the MongoDB instance
  imagePullSecret:
    enabled: true        # If true, enables pulling images from a private registry
    name: regcred        # Name of the Kubernetes image pull secret
  logs:
    enabled: false       # Enables or disables logging to file
    log_level: debug     # Log level for Open5GS components (options: none, fatal, error, warn, info, debug, trace)
  monitoring:
    prometheus:
      release:
        name: prometheus-5g  # Prometheus Helm release name for monitoring integration
  no_tls:
    enabled: true        # Disables TLS on all SBI interfaces (useful for dev/testing)
```



### 📦 Component images and metadata

Common image configuration shared by several components:

```yaml
<component>:
  image:
    repository: <image_repo>    # Docker image location
    tag: <image_tag>            # Version tag of the image
    pullPolicy: Always          # Image pull policy (e.g., Always, IfNotPresent)
```

* Applies to: `open5gs`, `ueransim`, `mongodb`
* `webui` additionally includes:

```yaml
  service:
    type: NodePort             # Exposes service via NodePort
    port: 3000                 # Internal container port
    target_port: 3000          # Target port inside container
    node_port: 30080           # External port on the node
  replicas: 1                  # Number of pod replicas
  node_selector:
    node: cloud                # Placement of the pod (e.g., cloud or edge node)
```

* `mongodb` additionally includes:

```yaml
  container_port: 27017        # Port exposed by MongoDB container
  service:
    port: 27017                # Service port for MongoDB access
    target_port: 27017         # Target port inside container
  node_selector:
    node: cloud
```



### 🧠 AMF - Access and Mobility Management Function

```yaml
amf:
  service:
    ngap:
      type: NodePort           # Exposes NGAP (N2) over NodePort
      port: 38412              # NGAP port
      target_port: ngap
      node_port: 30412         # External port
    sbi:
      port: 80
      target_port: sbi
    metrics:
      port: 9090               # Prometheus metrics port
      target_port: metrics
  replicas: 1
  container_port:
    ngap: 38412                # NGAP protocol port
    sbi: 80                    # SBI interface port
    metrics: 9090              # Prometheus metrics port
  node_selector:
    node: cloud
  configuration:
    mcc: '999'                 # Mobile Country Code
    mnc: '70'                  # Mobile Network Code
    tac: '100'                 # Tracking Area Code
    slice_sst_sd_list:         # Supported slices (SST/SD tuples)
      - sst: 1
        sd: 000001
    t3512: 540                 # Timer T3512 for periodic registration updates (in seconds)
    metrics:
      enabled: True            # Enable Prometheus metrics
      interval: "5s"           # Scrape interval
```



### 🧭 NSSF - Network Slice Selection Function

```yaml
nssf:
  service:
    sbi:
      port: 80
      target_port: 80
  replicas: 1
  container_port:
    sbi: 80
  node_selector:
    node: cloud
  configuration:
    nsi_list:
      - addr: nrf-svc          # NRF service address
        port: 80               # NRF port
        s_nssai:
          sst: 1               # Slice Service Type
          sd: 000001           # Slice Differentiator
```



### 🌐 SMF - Session Management Function

```yaml
smf:
  service:
    pfcp:
      port: 8805               # PFCP port for control-plane
      target_port: 8805
    sbi:
      port: 80
      target_port: 80
    metrics:
      port: 9090               # Prometheus metrics
      target_port: 9090
  replicas: 1
  container_port:
    pfcp: 8805
    sbi: 80
    metrics: 9090
  node_selector:
    node: cloud
  configuration:
    mtu: 1400                  # MTU for user-plane interfaces
    dns_list:                  # DNS servers assigned to UE
      - 8.8.8.8
      - 8.8.4.4
    subnet_list:
      - addr: 10.45.0.1/16     # IP pool for UEs
        dnn: internet          # Data Network Name
    pfcp_upf_connection_list:
      - name: upf-pfcp-svc     # Name of UPF service to connect
        port: 8805
    metrics:
      enabled: True
      interval: "5s"
```



### 🚚 UPF - User Plane Function

```yaml
upf:
  service:
    gtpu:
      name: upf-gtpu-svc       # GTP-U Service
      port: 2152               # GTP-U port
      target_port: 2152
      node_port: 32152         # External node port
    pfcp:
      name: upf-pfcp-svc
      port: 8805
      target_port: 8805
    nodeport:
      enabled: True
      type: NodePort           # Whether to expose via NodePort
    loadbalancer:
      enabled: True
      type: LoadBalancer       # Whether to expose via LoadBalancer
      loadBalancerIP: 10.201.0.11  # Fixed IP for MetalLB (if used)
  replicas: 1
  container_port:
    gtpu: 2152
    pfcp: 8805
  node_selector:
    node: cloud
  distributed_upf:
    enabled: false            # If true, deploys UPF in edge
    node_selector:
      node: cloud
  configuration:
    subnet_list:
      - addr: 10.45.0.1/16
        dnn: internet
        dev: ogstun0          # Device name for the tunnel
    pfcp_smf_connection_list:
      - name: smf-pfcp-svc
        port: 8805
```



### 🏗️ gNB - Simulated RAN

```yaml
gnb:
  enabled: false               # Set to true to deploy gNB pod
  service:
    ngap:
      port: 38412              # NGAP port
      target_port: 38412
    gtp:
      port: 2152               # GTP-U port
      target_port: 2152
  replicas: 1
  container_port:
    ngap: 38412
    gtp: 2152
  node_selector:
    node: cloud
  configuration:
    mcc: "999"
    mnc: "70"
    nci: "0x000000010"         # NR Cell Identity
    idLength: 32               # Length of gNB ID
    tac: 100                   # Tracking Area Code
    linkIp: "0.0.0.0"          # IP address of gNB link interface
    ngapIp: "0.0.0.0"
    gtpIp: "0.0.0.0"
    amfConfigs:
      - address: "amf-ngap-svc" # AMF NGAP service
        port: 38412
    slices:
      - sst: 1
        sd: "000001"
    ignoreStreamIds: true
```



### 📱 UE - Simulated user equipment

```yaml
ue:
  enabled: false               # Set to true to deploy UE pod
  replicas: 1
  node_selector:
    node: cloud
  configuration:
    supi: "imsi-999700000000000" # Subscriber ID
    mcc: "999"
    mnc: "70"
    key: "8baf473f2f8fd09487cccbd7097c6862"   # Authentication key
    op: "8e27b6af0e692e750f32667a3b14605d"     # Operator variant
    opType: "OPC"               # Type of operator code
    amf: "8000"                 # Authentication Management Field
    imei: "356938035643803"
    imeiSv: "4370816125816151"
    gnbSearchList:
      - 192.168.58.97          # gNB IPs to connect to
    uacAic:
      mps: false               # Mobile positioning services
      mcs: false               # Mission-critical services
    uacAcc:
      normalClass: 0
      class11: false
      class12: false
      class13: false
      class14: false
      class15: false
    sessions:           # Slices configuration
      - type: "IPv4"
        apn: "internet"
        slice:
          sst: 1
          sd: "000001"
    configurednssai:
      - sst: 1
        sd: "000001"
    defaultnssai:
      - sst: 1
        sd: "000001"
    integrity:
      IA1: true
      IA2: true
      IA3: true
    ciphering:
      EA1: true
      EA2: true
      EA3: true
    integrityMaxRate:
      uplink: "full"
      downlink: "full"
```



### 🧩 Other core services

The following services share nearly identical structure and config:

* **AUSF**, **BSF**, **NRF**, **PCF**, **UDM**, **UDR**

```yaml
<component>:
  service:
    sbi:
      port: 80
      target_port: 80
  replicas: 1
  container_port:
    sbi: 80
  node_selector:
    node: cloud
```

* `udm` also includes:

```yaml
  configuration:
    hnet:
      enabled: False          # Home network features toggle
```


## 🚀 Deploying with Helm

### 1. Install Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

### 2. Access your Kubernetes cluster

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
