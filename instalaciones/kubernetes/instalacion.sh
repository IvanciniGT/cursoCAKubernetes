# Instalación de docker
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update -y
sudo apt install docker-ce -y

# Configurar Docker para Kubernetes
if [[ $(cat /lib/systemd/system/docker.service | grep -c cgroupdriver=systemd) == 0 ]]
then
    sudo sed -i 's/--containerd=\/run\/containerd\/containerd.sock/--containerd=\/run\/containerd\/containerd.sock  --exec-opt native.cgroupdriver=systemd/' /lib/systemd/system/docker.service

    sudo systemctl daemon-reload
    sudo systemctl restart docker
fi
# Test de la instalación de docker
if [[ $(sudo systemctl status docker | grep -c cgroupdriver=systemd) == 1 ]]
then
    echo INFO. Docker instalado y configurado correctamente.
else
    echo ERROR. Error al configurar docker.
fi

# Desactivar la swap

sudo swapoff -a                             # Desactivación en la sesión actual
sudo sed -i 's/\/var/#\/var/' /etc/fstab    # Desactivación persistente

# Chequeo de el estado del swap
SWAP_ACTUAL=$(free | grep Swap)
if [[ "$SWAP_ACTUAL" =~ [1-9] ]]
then
    echo ERROR. No se ha podido desactivar la swap
else
    echo INFO. Swap desactivada correctamente
fi

# Todos requisito listos... A por Kubernetes !!!!
# Instalamos kubeadm < Como dependencias: kubelet + kubectl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo touch /etc/apt/sources.list.d/kubernetes.list
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install kubeadm -y

# Hasta aquí la instalación de KUBERNETES !!!!  EN CUALQUIER NODO DE CUALQUIER CLUSTER