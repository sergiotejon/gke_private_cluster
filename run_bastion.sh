#!/bin/bash

NET_IFACE=eth0
GKE_CLUSTER_NAME=$(terraform output -raw kubernetes_cluster_name)
GKE_CLUSTER_LOCAL_IP=$(terraform output -raw kubernetes_cluster_private_endpoint)
GKE_CLUSTER_PORT=443
LOCAL_PORT=8443
BASTION_PUBLIC_IP=$(terraform output -raw bastion_public_ip)
BASTION_USER=stejon


if [ ! -f ./terraform.tfvars ] ; then
   echo "Este script ha de ser ejecutado en el directorio donde se ubica la arquitectura en código con Terraform."; exit 1
fi

kubectl config set clusters.$(kubectl config get-contexts | grep $GKE_CLUSTER_NAME | awk '{print $2}').server https://$GKE_CLUSTER_LOCAL_IP:$LOCAL_PORT

sudo ip addr add $GKE_CLUSTER_LOCAL_IP/32 dev $NET_IFACE 2> /dev/null

echo "Se va a lanzar el túnel de acceso API de Kubernetes hacia el bastión..."
ssh -L $GKE_CLUSTER_LOCAL_IP:$LOCAL_PORT:$GKE_CLUSTER_LOCAL_IP:$GKE_CLUSTER_PORT \
	$BASTION_USER@$BASTION_PUBLIC_IP -N &
echo "Para cerrar el tunel: $ kill $!"
