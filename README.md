# Vault OSS with K3S & Multipass

## Why Multipass & k3s?

https://multipass.run/docs/installing-on-macos

Multipass uses Hyperkit on the Intel chips and qemu on the M1's as its back-end. It simplifies VM provisioning and allows you to have multiple dev environments up and ready within minutes of running the installer.

Kubernetes is a grind to learn and can be daunting for newcommers. K3s is a lightweight, simple and production-ready implementation of Kubernetes that greatly reduces the complexity and allows you to focus on how the larger parts function and move together. 

I found this setup to be the most straight forward method for spinning up multiple Vault clusters with Kubernetes and being able to access each via an IP address, as well as an easy way to pick up Kubernetes locally without needing Minikube.

There is also a built-in and pre-installed load balancer out of the box for k3s, as well as many other features pre-configured and ready to go, further reducing the complexity of getting started on Kubernetes.

## Prerequisites

- [Multipass](https://multipass.run/)

- [Git, or any other Git client](https://git-scm.com/)

- It also doesn't hurt to have [kubectl](https://kubernetes.io/docs/reference/kubectl/) installed on your host machine, though the Linux VM bootstraps with it installed and aliased to `k` so it's not really necessary.

## Setup & Installation

#### From your host machine

- Clone this repository, `cd` into the appropriate directory:

`git clone https://github.com/conor-mccullough/vault-k3s.git && cd vault-k3s`

- Launch your VM, targeting the `config.yaml` file which contains our cloud-init data used to bootstrap the instance:

`multipass launch -n <vm name> -m 4G -c 2 -d 10GB --cloud-init cloud-init/config.yaml`

- SSH to the new Multipass instance. Multipass uses the `shell` command in place of pure `ssh`:

`multipass shell <vm name>`

--- 

(If needed, the `ssh` command can be used to connect to instances by adding your hosts public key to the `authorized_keys` file on the new VM)

#### From the Multipass instance

`write-license.sh` bootstraps Vault semi-automatically. This script asks for & applies the license, launches Vault and its agent injector, and initialises Vault, storing your unseal key and root token in a newly generated `cluster-keys.json`.

Helm values are generated and written to `vault-overrides.yaml` by the `vault-overrides.sh` script based off the input given.


- Run the provisioning script:

`./write-license.sh`

- Enter the name for your Kubernetes secret, which Kubernetes will use to store your Vault license in.

- Paste the Vault Enterprise license string. This prompt uses `read -s` to avoid printing to screen so don't panic when nothing pops up.

- Enter the name for the pod on which we'll be running Vault.

- You'll be prompted to validate that the name you've generated matches your previous selection followed by `-0`. Hit enter if correct. CMD+C if incorrect and proceed to the troubleshooting section for next steps.

- The script waits for your pod to hit a `Ready` state. It then unseals and initializes Vault.

- [Ubuntu is funny with sourcing `.bashrc` from within another script](https://askubuntu.com/questions/64387/cannot-successfully-source-bashrc-from-a-shell-script), so manually force your session to reread it:

`source ~/.bashrc`

- Validate your environment variables are correct:

`vault token lookup`

`vault status`

## Cleanup

- Deleting the VM removes it from use and deletes its disk image, config files, etc - however it retains some data. As such, you'll need to delete **and** purge if you intend on reusing the same name for your next machine:

`multipass delete <vm name>`

`multipass purge`

- Or:

`multipass delete <vm name> --purge`


## Troubleshooting

#### General

- Validate that the `vault-overrides.yaml` was successfully written to and contains valid data.

- `helm uninstall <pod name without the -0>` will tear down the existing pod to be rebuilt.

#### Pod state fails to enter "Ready"

- List your pods to validate the state it's in:

`k get pods -A`

- If it's up but broken, check the logs:

`k logs <pod name>`

Commonly you'll see issues with the license popping up at this stage, usually it's either a typo or an incorrectly pasted license string provided during the bootstrap script.

- If it didn't reach a state where Vault was able to print logs, pull the pod event log:

`k get event --field-selector involvedObject.name=<pod name>`

- Validate the actual deployment parameters of your pod:

`k describe pod <pod name>`

#### Multipass not deleting machine after delete & purge

- Stop the VM:

`multipass stop <vm name>`

- Validate the existing virtual machines & their states:

`multipass ls`

- Delete the newly stopped VM:

`multipass delete <vm name> --purge`

- Validate it as successfully removed:

`multipass ls`

## Notes

The `scripts` directory is not used in this deployment, it just exists to provide the deployment scripts used in an easy to digest format.

Differences between a default k3s installation and k8s include, but are not limited to:

- K3s uses `sqlite` for storage instead of `etcd`, and also lacks other core features out of the box. This can all be configured if needed.

- Traefik is its default ingress controller.

- Klipper is used as the Service Load Balancer.
