# Talos

Every node runs [Talos Linux](https://www.talos.dev/), an immutable, API-driven OS built only to run Kubernetes. Nodes have no SSH or shell. [topf](https://github.com/postfinance/topf) builds their machine configs from the `talos/` directory and applies them.

## Cluster

| Setting | Value |
|---|---|
| Talos | ![Talos version](https://kromgo.jnobrega.com/badges/talos_version) |
| Kubernetes | ![Kubernetes version](https://kromgo.jnobrega.com/badges/kubernetes_version) |
| API endpoint | `https://192.168.1.110:6443` (a VIP shared by the control-plane nodes) |
| CNI | Cilium (Flannel and kube-proxy are disabled) |

| Node | Role | IP |
|---|---|---|
| bmax1-master | Control plane | 192.168.1.81 |
| soyo2-master | Control plane | 192.168.1.82 |
| soyo3-master | Control plane | 192.168.1.83 |
| hp-worker1 | Worker | 192.168.1.91 |
| hp-worker2 | Worker | 192.168.1.92 |
| hp-worker3 | Worker | 192.168.1.93 |
| localstorage-worker1 | Worker | 192.168.1.101 |

## Layout

```text
talos/
├── topf.yaml        # cluster name, endpoint, versions and the node list
├── secrets.yaml     # cluster PKI and tokens, SOPS-encrypted
├── all/             # patches for every node
├── control-plane/   # patches for control-plane nodes
├── worker/          # patches for workers
├── node/<host>/     # patches for a single node
└── schematics/      # Image Factory schematic for workers
```

topf starts each node's config from a base generated from `topf.yaml` and `secrets.yaml`. It then applies the patches in `all/`, the node's role directory (`control-plane/` or `worker/`) and finally `node/<host>/`. Later patches override earlier ones. Files ending in `.tpl` are Go templates and can use node fields such as `{{ .Node.Host }}`.

Patches use the multi-document config format introduced in Talos 1.14: each document has its own `kind` (`KubeletConfig`, `ResolverConfig` and so on) instead of nesting everything under `machine:` and `cluster:`.

## What the patches do

### All nodes

| Patch | Purpose |
|---|---|
| `01-kubelet` | Feature gates for graceful node shutdown and pod certificates, a 150-pod limit per node, and garbage collection of images unused for 72h |
| `02-kubePrism` | KubePrism on port 7445, an in-node load balancer for the API server |
| `03-containerd` | Keeps unpacked image layers, which Spegel needs to share images between nodes |
| `04-sysctls` | Larger network buffers, BBR congestion control, conntrack limit and hugepages |
| `05-cni` | Removes Flannel, since the bootstrap installs Cilium instead |
| `06-machine-cert-sans` | Adds the VIP to the Talos API certificate |
| `07-hostname` | Sets the hostname from the node's name in `topf.yaml` |
| `08-filesystem` | Weekly TRIM and scrub |
| `09-resolver` | Pi-hole first, Cloudflare (1.1.1.1) as fallback |
| `10-security-profile` | Turns off workload isolation |

### Control plane

| Patch | Purpose |
|---|---|
| `01-cluster` | Controller-manager feature gates; kube-proxy disabled, because Cilium replaces it |
| `02-apiserver` | Aggregator routing, plus feature gates and beta APIs (image volumes, mutating admission policies, pod certificates) |
| `03-etcd` | Exposes etcd metrics on `:2381` for Prometheus |
| `04-talos-api-access` | Lets pods in `system-upgrade` use the Talos API as `os:admin`, which Tuppr needs |
| `05-authentication` | Anonymous access only to health checks and the OIDC discovery endpoints |

### Workers

| Patch | Purpose |
|---|---|
| `01-nfs` | NFS 4.2 mount defaults for the NAS (`nconnect=8`, 128 KiB read and write sizes) |
| `02-kernel-modules` | Loads `nvme_tcp`, `vfio_pci` and `uio_pci_generic` |

Workers boot an [Image Factory](https://factory.talos.dev/) image built from `schematics/worker.yaml.tpl`. Every worker gets `iscsi-tools` and `util-linux-tools`, which Longhorn needs. `hp-worker3` also gets `amdgpu`, and `localstorage-worker1` gets `i915` for its GPU.

### Per node

Every node has an install-disk selector (`01-install`) and a DHCP link config (`02-network`). Beyond that:

| Node | Extra config |
|---|---|
| Control-plane nodes | Layer 2 VIP `192.168.1.110` on their network link |
| hp-worker2, hp-worker3 | Labelled for a default Longhorn disk, with a `longhorn` user volume on a separate SSD |
| localstorage-worker1 | Intel GPU label and `i915` module, plus an `openebs-local` user volume for OpenEBS local PVs |

## Day-to-day

Run these from `talos/`:

```sh
topf render    # render the machine configs without applying them
topf apply     # apply config changes to the running nodes
topf upgrade   # upgrade Talos on each node to the version in topf.yaml
```

Add `--nodes-filter <regex>` to work on only some nodes, for example `--nodes-filter hp-worker3`.

## Upgrades

Renovate opens PRs that bump `talosVersion` and `kubernetesVersion` in `topf.yaml`. Once one merges, run `topf upgrade` to move the nodes to the new version.

[Tuppr](https://github.com/home-operations/tuppr) runs in `system-upgrade`, and `k8s/apps/system-upgrade/tuppr/upgrade/` holds a `TalosUpgrade` and a `KubernetesUpgrade`. Both have a health check that holds back a node reboot until VolSync backups finish. Their Flux Kustomization (`tuppr-upgrades`) is commented out for now, so Tuppr doesn't upgrade anything and upgrades stay manual.
