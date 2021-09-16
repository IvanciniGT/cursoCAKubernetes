#!/bin/bash

wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml 

mkdir -p metrics
mv components.yaml metrics/metrics-server.yaml
sed -i 's/--secure-port=443/--secure-port=443\n        - --kubelet-insecure-tls/' metrics/metrics-server.yaml

if [[ $(cat metrics/metrics-server.yaml | grep -c insecure-tls) == 1 ]]
then
    kubectl apply -f metrics/metrics-server.yaml 
else
    echo ERROR. No se ha podido modificar correctamente el fichero de Metrics-Server para permitir la no comprobación de certificados.
    exit 1
fi
sleep 10
if [[ $(kubectl get pods -n kube-system | grep metrics-server | grep -c Running ) == 1 ]]
then
    echo INFO. Metrics server instalado correctamente
else
    echo ERROR. El pod de metrics-server no se ha inicializaco correctamente
    exit 1
fi