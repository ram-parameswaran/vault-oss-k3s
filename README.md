saving here for now

# Vault with K3S & Multipass

Most of this is just taken & pieced together from various guides I've found on the internet and internally at HashiCorp. Big thanks to Ranjan who shared [his own repository for Consul](https://github.com/Ranjandas/learn-consul-connect/tree/main/cloud-init/scripts) with me when he learned I was trying to set up something similar, saving several days of frustrating troubleshooting. 

## Why Multipass & k3s?

Due to compatibility limitations on the Mac M1 chips I feel most common solutions fell short or felt clunky in some way, which can be inhibiting, especially while attempting to learn Kubernetes and not being able to troubleshoot it effectively.

I found this setup to be the most straight forward method for spinning up multiple Vault clusters with Kubernetes and being able to access each via an IP address.

Kubernetes is a grind to learn and can be daunting for newcommers. K3s is a lightweight, simple and production-ready implementation of Kubernetes that greatly reduces the complexity and allows you to focus on how the larger parts function and move together. 

## Architecture

Details of how the repo functions go here

## Prerequisites

- [Multipass](https://multipass.run/)

- [Git, or any other Git client](https://git-scm.com/)

- It also doesn't hurt to have [kubectl](https://kubernetes.io/docs/reference/kubectl/) installed on your host machine, though the Linux VM bootstraps with it installed and aliased to `k` so it's not really necessary.

## Getting started

#### From your host machine

`multipass launch -n <vm name> -m 4G -c 2 -d 10GB --cloud-init cloud-init/multipass.yaml`

`multipass shell <nm name>`

#### From the VM

Copy the overrides.yaml to the VM

`secret=$(cat license.hclic)`
`k create secret generic vault-ent-license --from-literal="license=${secret}"`

`helm install vault hashicorp/vault --values overrides.yaml`

```
k exec v-vault-0 -- vault operator init \
    -key-shares=1 \
    -key-threshold=1 \
    -format=json > cluster-keys.json
```

`VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" cluster-keys.json)`

`k exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY`


## Cleanup

Cleanup steps here

## Notes

K3s uses `sqlite` for storage instead of `etcd`, and also lacks other core features out of the box. This can all be configured if needed.



