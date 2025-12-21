<h1 align="center"><div align="center">

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Kubernetes_logo_without_workmark.svg/1055px-Kubernetes_logo_without_workmark.svg.png" align="center" width="200px" height="194px"/>

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
├── 📁 backblaze
├── 📁 garage
└── 📁 minio

```
---

## Topology

<img src="./assets/hometopology.svg" align="center" width="500px" height="500px"/>

---

## :wrench:&nbsp; External Third-Party Components

These tools complement the Kubernetes infrastructure by providing essential functionality for **security**, **automation** and **infrastructure** management


<table>
            <tr>
                <th>Logo</th>
                <th>Tool</th>
                <th>Purpose</th>
            </tr>
            <tr>
                <td><img width="32" src="https://archive.org/download/github.com-mozilla-sops_-_2020-01-23_22-37-00/cover.jpg" alt="Sops logo" /></td>
                <td><a href="https://github.com/mozilla/sops">Sops</a></td>
                <td>A flexible tool for managing repository secrets securely.</td>
            </tr>
            <tr>
                <td><img width="32" src="https://pre-commit.com/logo.svg" alt="Pre-commit logo" /></td>
                <td><a href="https://github.com/pre-commit/pre-commit">Pre-commit</a></td>
                <td>Ensures consistency and quality of YAML and shell scripts in the repository.</td>
            </tr>
            <tr>
                <td><img width="32" src="https://docs.renovatebot.com/assets/images/logo.png" alt="Renovate logo" /></td>
                <td><a href="https://docs.renovatebot.com/">Renovate</a></td>
                <td>Automates the detection of new releases and creates pull requests accordingly.</td>
            </tr>
            <tr>
                <td><img width="32" src="https://cdn.brandfetch.io/idO1RZnoWN/w/400/h/400/theme/dark/icon.png?c=1dxbfHSJFAPEGdCLU4o5B" alt="Akeyless logo" /></td>
                <td><a href="https://console.akeyless.io/">Akeyless</a></td>
                <td>A centralized platform for managing and securing certificates, credentials, and keys.</td>
            </tr>
            <tr>
                <td><img width="32" src="https://icon.icepanel.io/Technology/svg/Cloudflare.svg" alt="Cloudflare logo" /></td>
                <td><a href="https://www.cloudflare.com/en-gb/">Cloudflare</a></td>
                <td>DNS management service for handling domain name resolutions.</td>
            </tr>
            <tr>
                <td><img width="32" src="https://images.icon-icons.com/699/PNG/512/gmx_icon-icons.com_61633.png" alt="GMX logo" /></td>
                <td><a href="https://www.gmx.com">GMX</a></td>
                <td>SMTP service provider for managing email communications.</td>
            </tr>
            <tr>
                <td><img width="32" src="https://icon.icepanel.io/Technology/svg/HashiCorp-Terraform.svg" alt="Terraform logo" /></td>
                <td><a href="https://www.terraform.io/">Terraform</a></td>
                <td>IAC tool for automating the provisioning and management of outside dependencies (Akeyless, Cloudflare, etc...).</td>
            </tr>
    </table>

## 🔧 Hardware


Hardware is a combination of mini PC's and desktop computers. Worker nodes have been upgraded to have more RAM.

<table>
        <thead>
            <tr>
                <th>Devices</th>
                <th>Count</th>
                <th>Disk Size</th>
                <th>RAM</th>
                <th>Operating System</th>
                <th>Purpose</th>
                <th>Model</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>Bmax1-master</td>
                <td>1</td>
                <td>128GB SSD</td>
                <td>8GB</td>
                <td>Talos v1.11.6</td>
                <td>Kubernetes Control</td>
                <td>Bmax B1Pro Gemini Lake N4000</td>
            </tr>
            <tr>
                <td>Soyo2-master</td>
                <td>1</td>
                <td>512GB SSD</td>
                <td>16GB</td>
                <td>Talos v1.11.6</td>
                <td>Kubernetes Control</td>
                <td>SOYO m2 plus v1</td>
            </tr>
            <tr>
                <td>Soyo3-master</td>
                <td>1</td>
                <td>512GB SSD</td>
                <td>16GB</td>
                <td>Talos v1.11.6</td>
                <td>Kubernetes Control</td>
                <td>SOYO m2 plus v1</td>
            </tr>
            <tr>
                <td>Hp-worker1</td>
                <td>1</td>
                <td>240GB SSD</td>
                <td>20GB</td>
                <td>Talos v1.11.6</td>
                <td>Kubernetes Worker</td>
                <td>Hp Elite Desk 800 G3</td>
            </tr>
            <tr>
                <td>Hp-worker2</td>
                <td>1</td>
                <td>1TB HDD + 240GB SSD</td>
                <td>28GB</td>
                <td>Talos v1.11.6</td>
                <td>Kubernetes Worker</td>
                <td>HP Compaq 8300 SFF</td>
            </tr>
            <tr>
                <td>Hp-worker3</td>
                <td>1</td>
                <td>500GB HDD + 240GB SSD</td>
                <td>32GB</td>
                <td>Talos v1.11.6</td>
                <td>Kubernetes Worker</td>
                <td>HP Compaq 8300 SFF</td>
            </tr>
            <tr>
                <td>LocalStorage-worker1</td>
                <td>1</td>
                <td>512GB SSD</td>
                <td>16GB</td>
                <td>Talos v1.11.6</td>
                <td>Kubernetes Worker</td>
                <td>SOYO Intel Alder Lake N95</td>
            </tr>
            <tr>
                <td>Raspberry PI 4</td>
                <td>1</td>
                <td>3TB (2 + 1)</td>
                <td>8GB</td>
                <td>Pi OS</td>
                <td>NAS - OpenMediaVault</td>
                <td></td>
            </tr>
            <tr>
                <td>TP-Link LS108G</td>
                <td>1</td>
                <td>-</td>
                <td>-</td>
                <td>-</td>
                <td>Switch</td>
                <td></td>
            </tr>
        </tbody>
    </table>

  ---

### Applications

#### Infrastruture Related

<table>
    <tr>
        <th>Logo</th>
        <th>Name</th>
        <th>Description</th>
    </tr>
    <tr>
        <td><img width="32" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/cert-manager.svg"></td>
        <td><a href="https://cert-manager.io/">Cert Manager</a></td>
        <td>Let's Encrypt Certificates for SSL/TLS</td>
    </tr>
    <tr>
        <td><img width="32" src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cilium.svg"></td>
        <td><a href="https://cilium.io/">Cilium</a></td>
        <td>CNI </td>
    </tr>
        <tr>
        <td><img width="32" src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQuQSJXRx5KbH4dtzk4dxVgw0Gtgk264x_TXw&s"></td>
        <td><a href="https://longhorn.io/">Longhorn</a></td>
        <td>Distributed block storage for POD's persistent volumes </td>
    </tr>
    </tr>
        <tr>
        <td><img width="32" src="https://garagehq.deuxfleurs.fr/images/garage-logo.svg"></td>
        <td><a href="https://garagehq.deuxfleurs.fr/">Garage</a></td>
        <td>S3 Object storage</td>
    </tr>
    <tr>
        <td><img width="32" src="https://github.com/kubernetes-sigs/external-dns/raw/master/docs/img/external-dns.png"></td>
        <td><a href="https://github.com/kubernetes-sigs/external-dns">External DNS</a></td>
        <td>Synchronizes exposed Kubernetes Services and Ingresses with DNS providers.</td>
    </tr>
    <tr>
        <td><img width="32" src="https://api.civo.com/k3s-marketplace/kubernetes-external-secrets.png"></td>
        <td><a href="https://external-secrets.io/latest/">External Secrets Operator</a></td>
        <td>Used with Akeyless Platform to retrieve and push secrets</td>
    </tr>
    <tr>
        <td><img width="32" src="https://cdn.worldvectorlogo.com/logos/traefik-1.svg"></td>
        <td><a href="https://traefik.io/traefik/">Traefik</a></td>
        <td>Reverse proxy and Ingress controller</td>
    </tr>
    <tr>
        <td><img width="32" src="https://cdn.brandfetch.io/id7QyaLp8E/w/768/h/768/theme/dark/logo.png?c=1dxbfHSJFAPEGdCLU4o5B"></td>
        <td><a href="https://tailscale.com/kb/1236/kubernetes-operator">Tailscale Operator</a></td>
        <td>Secure access to Kubernetes</td>
    </tr>
    <tr>
        <td><img width="32" src="https://avatars.githubusercontent.com/u/314135?s=48&v=4"></td>
        <td><a href="https://github.com/cloudflare/cloudflared">Cloudflared</a></td>
        <td>Cloudflare Tunnel client</td>
    </tr>
    <tr>
        <td><img width="32" src="https://avatars.githubusercontent.com/u/104819355?v=4"></td>
        <td><a href="https://www.dragonflydb.io/docs/getting-started/kubernetes-operator">Dragonfly</a></td>
        <td>Modern in-memory datastore, fully compatible with Redis and Memcached APIs</td>
    </tr>
    <tr>
        <td><img width="32" src="https://avatars.githubusercontent.com/u/47803932?s=48&v=4"></td>
        <td><a href="https://volsync.readthedocs.io/en/stable/">Volsync</a></td>
        <td>PVC backups using Restic</td>
    </tr>
    <tr>
        <td><img width="32" src="https://images.saasworthy.com/authentik_45882_logo_1698387041_24xfy.png"></td>
        <td><a href="https://goauthentik.io/">Authentik</a></td>
        <td>Open source identity provider</td>
    </tr>
    <tr>
        <td><img width="32" src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/flux-cd.svg"></td>
        <td><a href="https://fluxcd.io/">Flux CD</a></td>
        <td>GitOps tool of choice</td>
    </tr>
</table>

---

### NAS

The backbone of my home storage infrastructure is built on a Raspberry Pi 4 running [OpenMediaVault](https://www.openmediavault.org/), a dedicated network-attached storage solution. The system utilizes two SSDs (2TB + 1TB) configured to store:

-   Media content (books, audiobooks)
-   Longhorn volume backups
-   System configurations
-   Docker Containers Data

The NAS hosts several essential containers:

<table>
    <tr>
        <th>Service</th>
        <th>Description</th>
    </tr>
    <tr>
        <td><a href="https://www.postgresql.org/">Postgres</a></td>
        <td>Reliable relational database for persistent data storage</td>
    </tr>
    <tr>
        <td><a href="https://pi-hole.net/">PI-Hole</a></td>
        <td>Network-wide ad blocking and local DNS management</td>
    </tr>
    <tr>
        <td><a href="Tailscale exit node egressing over NordVPN">TailNord</a></td>
        <td>Tailscale exit node egressing over NordVPN</td>
    </tr>
</table>


---

## Gratitude and Thanks

Thanks to all the people who donate their time to the [Home Operations](https://discord.gg/home-operations) Discord
community. Be sure to check out [kubesearch.dev](https://kubesearch.dev/) for ideas on how to deploy applications or get
ideas on what you may deploy.
