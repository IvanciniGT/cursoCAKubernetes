
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

-------
HPA <<<<<
Horizontal   Pod   AutoScaler
    Min Pods: 5
    Max Pods: 10
    
Gestiona el escalado automaticamente de los pods


-------

Wp 1
    50% + 51%   PUFF !!!!
Wp 2            PUFF !!!!
    51%
    
4 nodos    
    25%
    
Necesito escalar ?    +    Alta Disponibilidad
    TENGO LOS PELOS COMO ESCARPIAS AHORA MISMO SI SOY EL ADMIN DE ESTE SISTEMA !!!!!
Si se cae 1: Se caen los 2

--------
Uso de CPU por parte de un POD
POD ahora mismo: 2 CPU
POD ahora mismo esta usando 200mc < 0.2 Del tiempo de un core....
    Cada segundo esta usando el "equivalente" a 20% de un core
        En la realidad puede ser que esté usando el 5% de 4 cores cada segundo


Oye, Kubernetes !!!
Cuando los pods estén usando de media un 50% de la CPU permitida... escala
Kubernetes responde:
    OK... ya puedo ver cuanto estan usando...
    Pero... no me has dicho cuanto les permites usar,.... Como calculo el % de uso?
    El % = ACTUAL/MAXIMO


-------
LIMITACION DE RECURSOS A UN CONTENEDOR
resources:
    requests:               # Esta si la va a a pasar
        cpu: 500m
        memory: 500Mi
    limits:                 # Esta no la vais a ver nunca
        cpu: 1
        memory: 1000Mi
        
Request: El mínimo que solicito como desarrollador para que mi contenedor trabaje en un estado adecuado
Limit: El máximo que kubernetes le va a entregar

Para que sirve el request? Quien usa esta información? En que momento se usa?
    Scheduller. En base a lo que se solicite,m el sched. colocara el pod en una determinada máquina.
    Maquina que tiene que tener disponible (no comprometido) esos recursos
    
                                    No comprometido
Nodo 1   2 cores 2 Gbs          >   0.5 core y 1 Gbs
    WP (1.5 cores y 1 Gbs)
Nodo2   3 Cores 3 Gbs           >   1 cores y 1.5 Gbs
    MariaDB  (1 cores y 1 Gbs)
        En el uso real... de repente se crece.. se viene arriba y:
            2.5 cores y 2.5 Gbs de RAM      > Sin problema
    Nginx ( 1 core y 0.5 Gbs de RAM) 
        
    NGINX quiere usar 1 core al completo.
        Que ocurre en este escenario?
            Decisión de Kubernetes...limitar el uso de CPU del mariaDB. El MAriaDB va mas lento de lo que podría
    
    MariaDB quiere usar mas memoria: 2.6 Gbs. Decision en este caso por parte de Kub?
        Se cruje el pod de mariadb !!! LIQUIDADO. RESTART
    
WP (1.5 cores y 1 Gbs) >> Sched: En cualquiera... pej. Nodo1
MariaDB  (1 cores y 1 Gbs) >> Sched: Nodo 2
Nginx ( 1 core y 0.5 Gbs de RAM) >> Decision Sched: Nodo 2
    
    
    
    
Nodo Tengo 2 gbs de ram
    MariaDB que habia solicitado 1 Gb pero esta usando 1.5 Gbs
    
    Y ahora en esta situación meto un nginx al que tengo que garantizar 1 Gb de RAM
        SI, hay memoria suficiente no comprometida.
        Hay hueco real? NO.. pues se hace... Kub reinicia MariaDB
    



Nodo 1      CPU 80%
Nodo 2      CPU 80%

Quizas hay un HPA que quiere escalar.... pero no puede... porque ya no queda hueco en las maquinas

Que estaría guay poder escalar?
    Los nodos <<<< Esto no lo hace kubernetes. pero si Openshift
    
    
De cara a controlar los costes: El objeto a utilizar: ResourceQuota
Para que vienen bien los LimitRange?
    Optimizar el reparto de recursos en el cluster
    
32 Gbs de RAM
Desarrollador Proyecto WEB:
    Namespace : 28 Gbs    < ResourceQuota
          Requests
    Pod 1: 31 Gbs
    Pod 2:  2 Gbs
    32Gbs < 31 = 1 Gbs
------------

NAMESPACE:
    Cuotas:
        Maximo 8 Gbs de RAM y 12 CPUs
    Pod A:
        Solicita 1 Gb de RAM y 1 CPU
    
    HPA Pod A: 
        Min 5 - 10

Arranco el sistema: Decision del HPA? Notificar al Deployment > 5 replicas
    Deployment > Replicaset
        ReplicaSet > Crear 5 pods
            Cada pod es analizado por el sched > Asignar a una maquina
                5 pods en funcionamiento con un uso total de:
                    5 Gbs de RAM y 5 CPUs
    CPU la tengo al 70% de media entre los 5 pods
    HPA:
        Son necesarios 4 pods mas > Deployment > replicaset > 4 pods mas
                                                                V
                                                              scheduler
                                                                1er pod: Lo asigna a una maquina
                                                                2º pod:  Lo asigna a una maquina
                                                                3er pod: Lo asigna a una maquina
                                                                4º pod:  Supera la cuota... no se asigna a ninguna maquina
                                                                
Existe el pod 4º dentro de kubernetes?  SI
    Estado?     Pending schedling. !!!!!

                                                                
                                                                
                                                                
-----
Dashboard
    No teniamos metricas
HPA
    No teniamos metricas

Montar metric-server
    Ya tenemos metricas
    
El HPA seguia sin funcionar?
    No podria calcular % . Faltaban establecer limites
    
    
resources < POD (requests***, limits)                           <<< Desarrollo

ResourceQuotas < A nivel de NS
LimitRange     < A nivel de pod o contenedor dentro de un ns    <<< Admin cluster


Bitnami < Wordpress

-------
HTTPS:

Certificado de mi sitio (Nombre servidor)
    Clave publica
Clave privada

Todo ello firmado por una CA reconocida

CA reconocida que hoy en dia se usa muchisimo... 
    por generar certificados gratuitos

Let's encrypt
    Hay un módulo para Kubernetes de Let's encrypt
    que genera certificados automaticamente y se
    encarga de su renovación
    
    
    
    
    



