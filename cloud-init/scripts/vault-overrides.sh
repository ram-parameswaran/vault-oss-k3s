#!/bin/bash
touch vault-overrides.yaml
tee vault-overrides.yaml << EOF
server:
    image:
    repository: hashicorp/vault
    tag: 1.13.1
    affinity: ""
    ha:
    enabled: true
    replicas: 1
    apiAddr: null
    clusterAddr: "https://PLACEHOLDER_ADDRESS:8201"
    raft:
        enabled: true
        setNodeId: true
ui:
    enabled: true
    publishNotReadyAddresses: true
    activeVaultPodOnly: false
    serviceType: "LoadBalancer"
    serviceNodePort: null
    externalPort: 8200
    targetPort: 8200

fullnameOverride: PLACEHOLDER_VALUE

EOF