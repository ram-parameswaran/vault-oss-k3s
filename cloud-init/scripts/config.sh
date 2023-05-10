#!/bin/bash
~/vault-overrides.sh
export PLACEHOLDER_VALUE="my-value"
export PLACEHOLDER_ADDRESS="my-address"
read -p "Enter Kubernetes secret key name for Vault license (NOT Vault License itself): " KUBES_SECRET
printf "Enter Vault license key: \n"
read -s VAULT_LICENSE
IP_ADDR=$(ip a | grep enp0s1 | awk -v RS='([0-9]+\\.){3}[0-9]+' 'RT{print RT}' | head -n 1)
echo $VAULT_LICENSE > /home/ubuntu/license.hclic
SECRET=$(cat license.hclic); kubectl create secret generic $KUBES_SECRET --from-literal="license=${SECRET}"
read -p "Enter Vault pod name: " VAULT_NAME

sed -i "s/PLACEHOLDER_LICENSE/${KUBES_SECRET}/g" vault-overrides.yaml
sed -i "s/PLACEHOLDER_VALUE/${VAULT_NAME}/g" vault-overrides.yaml
sed -i "s/PLACEHOLDER_ADDRESS/${IP_ADDR}/g" vault-overrides.yaml

printf "%s\n" "-------------------------------------------------------------------"
sleep 2
helm install $VAULT_NAME hashicorp/vault --values vault-overrides.yaml --debug
printf "%s\n" "-------------------------------------------------------------------"
sleep 3
MY_POD=$(kubectl get pods | grep -m1 "${VAULT_NAME}" | awk '{printf $1}')
read -p "THE VAULT NAME IS BEING PARSED AS ${MY_POD} ------ CONTINUE?"
echo $MY_POD
until [[ $VAULT_POD_STATE == "Running" ]]
do
    VAULT_POD_STATE=$(kubectl get pod $MY_POD | awk 'FNR==2{printf $3}')
    printf "\nPod is currently: $VAULT_POD_STATE\n"
    sleep 2
done
printf "%s\n" "-------------------------------------------------------------------"
printf "Vault is ready, proceeding to unseal and init!\n"
printf "%s\n" "-------------------------------------------------------------------"
kubectl exec $MY_POD -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" cluster-keys.json)
kubectl exec $MY_POD -- vault operator unseal $VAULT_UNSEAL_KEY
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=$(jq -r ".root_token" cluster-keys.json)
printf "%s\n" "-------------------------------------------------------------------"
printf "Validating Vault status & root token lookup\n"
printf "%s\n" "-------------------------------------------------------------------"
vault status && printf "%s\n" "-------------------------------------------------------------------" && vault token lookup
echo "export VAULT_ADDR=http://127.0.0.1:8200" >> ~/.bashrc
echo "export VAULT_TOKEN=$(jq -r ".root_token" cluster-keys.json)" >> ~/.bashrc
