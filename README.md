# Vault with K3S

## Vault on k3s with Multipass

Due to compatibility limitations on the Mac M1 chips I found most common solutions fell short or felt clunky in some way, which can be inhibiting, especially while attempting to learn Kubernetes and not being able to troubleshoot it effectively.

I found this setup to be the most straight forward for spinning up multiple Vault clusters with Kubernetes and being able to access each via an IP address.

Kubernetes is a grind to learn and can be daunting for newcommers. K3S is a lightweight, simple and production-ready implementation of Kubernetes that greatly reduces the complexity and allows you to focus on how the larger parts function and move together. 

Note that some things won't be installed and running out of the box - for example, k3s uses `sqlite` for storage instead of `etcd`. This can all be configured if you need it, though.

## Prerequisites

[Multipass](https://multipass.run/)

It also doesn't hurt to have [kubectl](https://kubernetes.io/docs/reference/kubectl/) installed on your host machine, though the Linux VM bootstraps with it installed and aliased to `k` so it's not really necessary.

## Getting started

`multipass launch -n <vm name> -m 4G -c 2 -d 10GB --cloud-init cloud-init/multipass.yaml`

etc etc etc, to modify later




