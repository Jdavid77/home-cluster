<h1 align="center"><div align="center">

<img src="docs/src/assets/logo.png" align="center" width="200px" height="194px"/>

### Kubernetes cluster

... managed using Talos, Flux and Renovate

</div>
</h1>



---

## 📖 Overview

This repository houses the code responsible for managing my home infrastructure.

The setup is based on Talos OS. I used [Talhelper](https://budimanjojo.github.io/talhelper/latest/) to generate the initial configs. Following the cluster deployment, Flux continuously monitors this repository for changes, and Renovate is used to handle automated dependency updates.


---

## Repository Structure

```
📁 infrastructure
└── 📁 talos
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

## :wrench:&nbsp; Tools

Here's the updated table including Terraform:

| Tool                                                       | Purpose                                                                 |
|-------------------------------------------------------------|-------------------------------------------------------------------------|
| [Sops](https://github.com/mozilla/sops)                     | A flexible tool for managing repository secrets securely.               |
| [Pre-commit](https://github.com/pre-commit/pre-commit)      | Ensures consistency and quality of YAML and shell scripts in the repository. |
| [Renovate](https://docs.renovatebot.com/)                   | Automates the detection of new releases and creates pull requests accordingly. |
| [Akeyless](https://console.akeyless.io/)                    | A centralized platform for managing and securing certificates, credentials, and keys, used in conjunction with External Secrets. |
| [Cloudflare](https://www.cloudflare.com/en-gb/)             | DNS management service for handling domain name resolutions.            |
| [GMX](https://www.gmx.com)                                  | SMTP service provider for managing email communications.                |
| [Terraform](https://www.terraform.io/)                      | IAC tool for automating the provisioning and management of outside dependencies (Akeyless, Cloudflare, etc...). |

---

## 🔧 Hardware


Here's the updated table with the links added:

| Devices          | Count | OS Disk Size | RAM  | Operating System | Purpose            | Links                                                                                                  |
|------------------|-------|--------------|------|------------------|--------------------|--------------------------------------------------------------------------------------------------------|
| Bmax1-master     | 1     | 128GB        | 8GB  | Talos v1.8.2     | Kubernetes Control | [Amazon Link](https://www.amazon.es/dp/B0CJM1TDHL?ref=ppx_yo2ov_dt_b_fed_asin_title)                   |
| Soyo1-master     | 1     | 64GB         | 6GB  | Talos v1.8.2     | Kubernetes Control | [AliExpress Link](https://es.aliexpress.com/item/1005006460890415.html?aff_fcid=505c2a4499e846b2a13fde87aa7c7385-1733566005358-08415-_DBcuZW1&tt=CPS_NORMAL&aff_fsk=_DBcuZW1&aff_platform=portals-tool&sk=_DBcuZW1&aff_trace_key=505c2a4499e846b2a13fde87aa7c7385-1733566005358-08415-_DBcuZW1&terminal_id=bb14814936f042d6a7ff280cc2d52e01&afSmartRedirect=y) |
| Soyo2-master     | 1     | 64GB         | 6GB  | Talos v1.8.2     | Kubernetes Control | [AliExpress Link](https://es.aliexpress.com/item/1005006460890415.html?aff_fcid=505c2a4499e846b2a13fde87aa7c7385-1733566005358-08415-_DBcuZW1&tt=CPS_NORMAL&aff_fsk=_DBcuZW1&aff_platform=portals-tool&sk=_DBcuZW1&aff_trace_key=505c2a4499e846b2a13fde87aa7c7385-1733566005358-08415-_DBcuZW1&terminal_id=bb14814936f042d6a7ff280cc2d52e01&afSmartRedirect=y) |
| Hp-worker2       | 1     | 240GB        | 28GB | Talos v1.8.2     | Kubernetes Worker  | [Amazon Link](https://www.amazon.es/dp/B0792TQ4XS?ref=ppx_yo2ov_dt_b_fed_asin_title)                   |
| Hp-worker3       | 1     | 240GB        | 32GB | Talos v1.8.2     | Kubernetes Worker  | [Amazon Link](https://www.amazon.es/dp/B0792TQ4XS?ref=ppx_yo2ov_dt_b_fed_asin_title)                   |
| Raspberry PI 4   | 1     | 3TB (2 + 1)  | 8GB  | Pi OS            | NAS (OMV)          |                                                                                                        |
| TP-Link LS108G   | 1     | -            | -    | -                | Switch             |                                                                                                        |

Let me know if you'd like any further modifications!
---

## Gratitude and Thanks

Thanks to all the people who donate their time to the [Home Operations](https://discord.gg/home-operations) Discord
community. Be sure to check out [kubesearch.dev](https://kubesearch.dev/) for ideas on how to deploy applications or get
ideas on what you may deploy.
