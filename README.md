# Vault with K3S & Multipass

## Why Multipass & k3s?

https://multipass.run/docs/installing-on-macos

- Multipass uses Hyperkit on the Intel chips and qemu on the M1's as its back-end

Due to compatibility limitations on the Mac M1 chips I feel most common solutions for setting up customer reproductions fell short or felt clunky in some way, which can be inhibiting, especially while attempting to learn Kubernetes and not being able to troubleshoot it effectively.

I found this setup to be the most straight forward method for spinning up multiple Vault clusters with Kubernetes and being able to access each via an IP address.

Kubernetes is a grind to learn and can be daunting for newcommers. K3s is a lightweight, simple and production-ready implementation of Kubernetes that greatly reduces the complexity and allows you to focus on how the larger parts function and move together. 

## Prerequisites

- [Multipass](https://multipass.run/)

- [Git, or any other Git client](https://git-scm.com/)

- It also doesn't hurt to have [kubectl](https://kubernetes.io/docs/reference/kubectl/) installed on your host machine, though the Linux VM bootstraps with it installed and aliased to `k` so it's not really necessary.

## Getting started

#### From your host machine

`multipass launch -n <vm name> -m 4G -c 2 -d 10GB --cloud-init cloud-init/config.yaml`

`multipass shell <nm name>`

#### From the VM

`./write-license.sh`

This script asks for & applies the license, launches Vault and its agent injector, and initialises Vault, storing your unseal key and root token in a newly generated `cluster-keys.json`.

It then takes these values, unseals Vault, and runs a `vault status` & `vault token lookup` to validate that it has been successful.

`export VAULT_ADDR=http://127.0.0.1:8200`

`export VAULT_TOKEN=$(jq -r ".root_token" cluster-keys.json)`

`vault status && vault token lookup`

## Cleanup

Cleanup steps here

`multipass delete <vm name>`

`multipass purge`

## Notes

K3s uses `sqlite` for storage instead of `etcd`, and also lacks other core features out of the box. This can all be configured if needed.

## Troubleshooting

#### Multipass not deleting machine after delete & purge

`multipass stop`
`multipass list`
`multipass delete <vm name> --purge`
`multipass list`
