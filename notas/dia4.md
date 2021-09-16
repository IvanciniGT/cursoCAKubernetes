
Pod1 
    Wordpress < Contenedor 1
Pod2
    MariaDB   < contenedor 2

Por qué montar 2 pods?
    Escalado independiente
    
No montamos pods, sino que trabajamos con plantillas: HA y escalabilidad gestionada por el propio Kubernetes.
    Wordpress:  Deployment      Todos los pods que se generen comparten volumen(es)
    MariaDB:    StatefulSet     Cada pod que se genera tiene su propio volumen(es)

2 servicios:
    Wordpress:  NodePort
    MariaDB:    ClusterIP
    
En kubernetes existen 3 tipos de servicios
    ClusterIP - Comunicaciones internas
            Balanceo de carga + Nombre DNS
        > NodePort - Comunicaciones externas
                + Abría un puerto en la red pública de los nodos del cluster (hosts)
                (Limitación: Me hace falta un BC externo al cluster que balancee entre las máquinas del cluster + DNS externo)
            > LoadBalancer    
                    + Kubernetes se encarga de gestionar un BC externo al cluster compatible - MetalLB

A la hora de definir los ficheros de Kubernetes (descriptores), vimos que realmente eran confeccionados por 
distintos perfiles:
    - Desarrollo:       Servicios + App=(Deployments-Statefulset) + PVCs
    - Administración:   Namespace + PVs
    - DBA:              ConfigMap + Secrets

ConfigMap + Secrets =
    Objetos gestionados por distintos perfiles
    Flexibilidad
        Podemos cargar el mismo archivo de despliegue (Desarrollador) en varios entornos (namespaces) pero cada
        uno con sus propias configuraciones.

----------------------
En un entorno real de producción:

Cómo van a ser la mayor parte de los servicios (de que tipo)?                  FAIL !!      EN LA REALIDAD
    ClusterIP           Comunicaciones internas                             60%     40%         Todos - 1
    NodePort            Comunicaciones externas (con BC externo)             0%      0%         0
    LoadBalancer        Comunicaciones externas (con BC autogestionado)     40%     60%         1    
    
INGRESS-Controller:
    Proxy-reverso. A través de una única entrada podemos llegar a múltiples destinos
    Gestión de colas
        Si es una pieza de software que se ejecutará dentro del cluster
            NGINX < Soportado y gestionado por Kubernetes
            
Nginx | Apache como proxy reverso?
    VirtualHosts: 
        URL Entrada: Normalmente nombres DNS o rutas
            app1.ca.ad > App1           |
            app2.ca.ad > App2           >    INGRESS: Reglas para un IngressController
            app2.ca.ad/mobile > App3    |


------------------------------------------
Monitorización de PODS
    Monitoriza cada uno de los contenedores del POD
        De cada Contenedor se fija en el proceso 1 (el del command del contenedor)
    
    startUpProbes
        Son pruebas para determinar si el contenedor está arrancado > Implica que esté listo para dar servicio?
            NO, por qué? ejemplos:
                Wordpress < Pte de configuración > No está listo para dar servicio
        Una vez que se dan por OK, ya no se ejecutan más
        
        QUE PASA SI LA PRUEBA DE STARTUP NO SE DA POR VALIDA? QUE HACE KUBERNETES?
            Liquida el POD y lo recrea
    livenessProbes
        Verificar con cierta PERIODICIDAD que el contenedor sigue corriendo en estado saludable
        Que esté corriendo implica que esté prestando servicio?
            BBDD: Por las noches se pone a hacer un backup en frio... No quiero que los usuarios entren a la BBDD
                  y el admin pone la BBDD en estado offline  
                  En este escenario: El proceso de la BBDD está vivo?   SI
                Está prestando servicio a usuarios?                     NO
        QUE PASA SI LA PRUEBA DE LIFENESS NO SE DA POR VALIDA? QUE HACE KUBERNETES?
            Liquida el POD y lo recrea
    ---------------------------
    ReadynessProbe
        Verificar con cierta PERIODICIDAD que el contenedor está listo para prestar servicio
            Implica que está vivo.
        QUE PASA SI LA PRUEBA DE READYNESS NO SE DA POR VALIDA? QUE HACE KUBERNETES?
            Saca el POD del listado de PODS de backend del SERVICE Asociado.
        
            BBDD: Por las noches se pone a hacer un backup en frio... No quiero que los usuarios entren a la BBDD
                  y el admin pone la BBDD en estado offline  
                  En este escenario: El proceso de la BBDD está vivo?   SI
                Está prestando servicio a usuarios?                     NO
            
------------
ServiceAccount:
    Cuenta de Servicio - Privilegios dentro de Kubernetes
    
Cuando un usuario (PERSONA FISICA) se conecta a un cluster lo hace a través de un service account.
Ese service account tiene asociados unos ROLES. Los roles tendrán asociados unos privilegios.
Esos privilegios a su vez será combinaciones de OBJETOS con VERBOS:
    POD < create, -delete, get, describe
    DEPLOYMENT < create, get, describe
    PVC < create, get
    
Pero las cuentas de servicio (ServiceAccount) no se usan solamente por personas... sino también por PROGRAMAS
Programas que quieran interlocutar con el Cluster.



