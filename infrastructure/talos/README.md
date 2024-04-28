## Step 1: Download Talos ISO

1 - Create an `assets` folder with the extensions that you wanna use:

e.g

```yaml
customization:
  systemExtensions:
    officialExtensions:
      - siderolabs/iscsi-tools
      - siderolabs/util-linux-tools
```

2 - Upload the schematic to the Image Factory to retrieve its ID:

e.g 

```bash
$ curl -X POST --data-binary @bare-metal.yaml https://factory.talos.dev/schematics
{"id":"b8e8fbbe1b520989e6c52c8dc8303070cb42095997e76e812fa8892393e1d176"}
```

Your ISO image should be available at:
https://factory.talos.dev/image/b8e8fbbe1b520989e6c52c8dc8303070cb42095997e76e812fa8892393e1d176/v1.7.0/metal-amd64.iso


## Step 2: Install Talos

Burn the downloaded ISO to a USB drive or attach it to your virtual machine. Boot each node from the ISO and follow the installation instructions.

## Step 3: Generate Secrets

```bash
talosctl gen secrets
```

## Step 4: Generate Configuration Files

Talos operates using a set of configuration files for each node type (control plane and worker). Use the talosctl command-line tool to generate these configurations.

```bash
talosctl gen config <cluster-name> <endpoint>
```

Replace <cluster-name> with your desired cluster name and <endpoint> with the endpoint IP address or DNS.

## Step 5: Apply Configuration

Apply the generated configuration files to each node using talosctl. This command initializes the node configurations.

```bash
talosctl apply-config --insecure -n <node-ip> -e <node-ip> --talosconfig <config-file> 
```

Replace <node-ip> with your node's IP address and <config-file> with the path to the configuration file.

## Step 6: Bootstrap the Control Plane

Bootstrap the Kubernetes control plane on the control plane nodes. This will start the Kubernetes API server and other control plane components.

```bash
talosctl bootstrap -n <node-ip> -e <node-ip> --talosconfig <config-file> 
```

Props to @mirceanton for the tutorial: https://www.youtube.com/watch?v=4_U0KK-blXQ&t=1208s