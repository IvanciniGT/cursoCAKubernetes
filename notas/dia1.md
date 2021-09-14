
PLANO DE CONTROL DE KUBERNETES: Controlplane

coredns
apiserver
scheduller
etcd
manager


Configurar una red virtual

Creación del cluster

sudo kubeadm init --pod-network-cidr=10.244.0.0/16


NAMESPACE:
    Agrupación lógica de algunos tipos de objetos en Kubernetes
                                            PODS
                                            SERVICES             * ISTIO - VirtualService
                                            CONFIGMAPS
                                            SECRETS
                                            NETWORK_POLICIES    * ISTIO
                                            ...
                                            
Namespace:
    Dentro de un NS montaré una app
    Entorno prod / pre / des
    
    


PODS:
    Pod1:
        C1: nginx
        C2: mariadb
ESTO NO LO HARIAMOS: quiero escalarlos de forma independiente

    Pod1:               IP.1
        C1: nginx
    Pod2:               IP.2
        C2: mariadb

nginx   Servidor WEB  >>>> mariadb BBDD
    nginx.conf (Dirección del mariaDB)
    ¿Qué dirección pongo?
        Puedo poner la IP . PERFECTAMENTE !!!!
        Lo haré? NUNCA JAMAS EN LA VIDA. POR QUE?
            1 - A priori conozco la IP del mariaDB?
            2 - Aunque la conozca... Esta sujeta a cambios
    ¿Cómo lo hago?
        1º Invento un Nombre DNS
        2º Lo registro en un Servidor DNS
            3º Con que IP? ... uff ya estamos.. lo miro a ver
        4º Que pasa cada vez que cambia la IP?
            Tengo que cambiar la configuracion del Servidor DNS

    SERVICE
