<h1 align="center"><div align="center">

<img src="docs/src/assets/logo.png" align="center" width="200px" height="194px"/>

### Kubernetes cluster

... managed using Talos, Flux and Renovate

</div>
</h1>



---

## 📖 Overview

---

## ⛵ Kubernetes

---

## Repository Structure

```
📁 infrastructure  
└── 📁 talos           # applications
    ├── 📁 clusterconfig  # holds the talos configuration for each node
    ├── 📁 integrations   # helmfile for initial deployments
    ├── 📁 patches        # talos patches
    └── talconfig.yaml          
    └── talsecret.sops.yaml          
📁 k8s  
├── 📁 apps           # applications
├── 📁 bootstrap      # bootstrap procedures
└── 📁 flux           # core flux configuration
📁 terraform  
├── 📁 authentik           
├── 📁 akeyless      
└── 📁 cloudflare           

```

---

## 🔧 Hardware


| Devices          | Count | OS Disk Size | RAM  | Operating System | Purpose            |
|------------------|-------|--------------|------|------------------|--------------------|
| Bmax1-master     | 1     | 128GB        | 8GB  | Talos v1.7.4     | Kubernetes Control |
| Hp-worker2       | 1     | 240GB        | 24GB | Talos v1.7.4     | Kubernetes Worker  |
| Hp-worker3       | 1     | 240GB        | 20GB | Talos v1.7.4     | Kubernetes Worker  |
| Raspberry PI 4   | 1     | 3TB (2 + 1)  | 8GB  | Pi OS            | NAS (OVM)          |
| TP-Link LS108G   | 1     | -            | -    | -                | Switch             |
---

## Gratitude and Thanks

Thanks to all the people who donate their time to the [Home Operations](https://discord.gg/home-operations) Discord
community. Be sure to check out [kubesearch.dev](https://kubesearch.dev/) for ideas on how to deploy applications or get
ideas on what you may deploy.