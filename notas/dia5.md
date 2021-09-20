Dashboard
    Faltaban métricas sobre el uso de CPU y Memoria por parte de los contenedores/Pods
HPA - Horizontal Pod Autoscaler
    En base a una metricas solicitar un autoescalado en un rango.
MetricServer
El HPA seguía sin funcionar porque no habíamos definido ni límites, ni recursos garantizados a los pods/contenedores

Control de recursos:
    Desarrollador:
        POD/PODTEMPLATE:
            resources:
                requests:   **** Esto es lo que nos dan al final
                    # Lo que necesito que me garanticen para poder ejecutar el pod / contenedor 
                        # Lo usa el Scheduler
                limits:
                    # Hasta cuanto me pueden llegar a dar, si hay hueco.
            Podemos tener un problema con la RAM.
    Administrador:
        ResourceQuota
            Establecer limitaciones a nivel de Namespace
        LimitRange
            Establecer limitaciones a nivel de Pod/Contenedor, eso si, dentro de un namespace

HELM - chart
    NFS-Provisioner 
    
------------------------------------------------------------------------------------------------
Ubicación de PODS
------------------------------------------------------------------------------------------------
Quién decide donde van los pods? Scheduler
    En base a los recursos disponibles en cada nodo
    En base a los recursos solicitados por el desarrollador

Desarrollador.....
    POD/PODTEMPLATE:
        Indicaciones sobre dónde se debería o no acomodar el pod.
            nodeName: ip-172-31-7-169
    
            nodeSelector:   # Mas flexible que nodeName... pero aún así... no muy flexible... PERO MUY SENCILLA / COMODA
                            # Labels: Etiquetas
                # kubernetes.io/hostname: ip-172-31-7-169
                            # kubectl label node NOMMBRE_NODO ETIQUETA=VALOR         <<<< Administrador
                            # kubectl label node ip-172-31-7-169 tipo-disco=ssd
                tipo-disco: ssd
                gpu: True
            
            affinity:
                nodeAffinity:
                    requiredDuringSchedulingIgnoredDuringExecution:
                        nodeSelectorTerms:
                            - matchExpressions:
                                - key: gpu
                                  operator: Lt   # NotIn Exists, DoesNotExists, Gt, Lt
                                  values:
                                    - 2
                                    
                    preferedDuringSchedulingIgnoredDuringExecution:
                        - weight: 10
                          preference:
                            - matchExpressions:
                                - key: gpu
                                  operator: Lt   # NotIn Exists, DoesNotExists, Gt, Lt
                                  values:
                                    - 2
                                
                podAntiAffinity:
                    preferedDuringSchedulingIgnoredDuringExecution:
                    requiredDuringSchedulingIgnoredDuringExecution:
                        - topologyKey: kubernetes.io/hostname
                          labelSelector:
                            - matchExpressions:
                                - key: app
                                  operator: In   # NotIn Exists, DoesNotExists, Gt, Lt
                                  values:
                                    - oracle

2 Pods de Oracle .... Cada pod se genera con una label:    app: oracle

Nodo 1
    ¿ Hay algun pod que tenga la etiqueta Oracle ? NO
    ¿ Generaré anti afinidad con ese nodo ? NO
    ¿ Aqui me puedo instalar? SI
    Pod 1 de Oracle
     ¿ Hay algun pod que tenga la etiqueta Oracle ? SI
    ¿ Generaré anti afinidad con ese nodo ? SI
    ¿ Aqui me puedo instalar? NO
Nodo 2
    ¿ Hay algun pod que NO tenga la etiqueta Oracle ? NO
    ¿ Generaré anti afinidad con ese nodo ? SI
    Pod 2 de Oracle
                podAntiAffinity:
                    preferedDuringSchedulingIgnoredDuringExecution:
                    requiredDuringSchedulingIgnoredDuringExecution:
            
            
Administrador.....
    Los admin... dan configuraciones a nivel de pod?
        El administrador trabajará a nivel de NODO
            El administrador puede decidir que un nodo repela pods 
    
        TAINT   son una especie de etiquetas de los nodos
        
            kubectl taint node NOMBRE_NODO etiqueta=valor:NoSchedule
                <<< El nodo no va a aceptar más pods
            kubectl taint node NOMBRE_NODO etiqueta=valor:NoExecute
                <<< El nodo va a desaguar todo lo que tiene... se queda pelao. sin pods
        
            kubectl taint node NOMBRE_NODO app-type=servidor-web:NoSchedule
            kubectl taint node NOMBRE_NODO perico=de-los-palotes:NoSchedule
                De entrada esta regla (taint) hace que NI UN SOLO POD puede ir al nodo
                    a no ser que el pod venga con una tolerancia al taint
                
            POD/POD-TEMPLATE:
                tolerations:
                    - key:      app-type
                      operator: Equal
                      value:    servidor-web
                      effect:   NoExecute             # "NoSchedule"
                    - key:      app-type
                      operator: Exists
                      effect:   NoExecute             # "NoSchedule"
            kubectl taint node NOMBRE_NODO app-type=servidor-web:NoExecute

------------------------------------------------------------------------------------------------

Casos de uso:
    
    - Máquinas de diferentes características
        - Distinto SO
        - Distinta arquitectura: x64 | arm
        - Una máquina con una tarjeta gráfica especial:
            Data mining, Machine learning => GPU
        - Más Memoria proporcionalmente que el resto
    
    - Distribucion geográfica
    
    - Controlar la carga de alguna forma
        Nodo1:
            MariaDB
            Nginx
        Nodo2: 
            MySQL
            Apache 
    
        Tengo 2 nodos físicos
            Nodo1
                Oracle
                WAS 2
            Nodo2
                Oracle Replicacion
                WAS 1
            
---------
Por defecto los nodos llevan estas etiquetas:

Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=ip-172-31-7-169
                    kubernetes.io/os=linux
                    node-role.kubernetes.io/control-plane=
                    node-role.kubernetes.io/master=
                    node.kubernetes.io/exclude-from-external-load-balancers=
                    
Cuando creamos un servicio de tipo LoadBalancer
    BC < IP interna al cluster       * ClusterIP
    Nombre DNS  interno al cluster   * ClusterIP
    Apertura de puerto en los hosts   [30000-327XX]    * NodePort
    Gestión automatizada de un BC Externo   * LoadBalancer
                                ^ MetalLB
        IP publica - BC ----> El puerto NodePort correspondiente de cada host del cluster
        
        
    Cliente
    BC <<< 192.168.X.X
    Cluster Kub    
        Nodo1 :30080 - Excluido del BC
            Maestro - CP Kub
        Nodo2 :30080
            POD/C:              10.0.0.100
                WAS: 7001
        Nodo3 :30080
            POD/C:              10.0.0.101
                WAS: 7001
            
        IP del servicio (BC) Interna al cluster: 10.10.0.100:7001 > 10.0.0.100:7001, 10.0.0.101:7001
                                                    ^^^^
                                                    mis-was:7001
        Cuando hay una peticion al puerto 30080 de cualquier nodo -> mis-was:7001
        
        
        
------------
podAntiAffinity:                           Generamos Antiafinidad con los nodos
                                           que comparten kubernetes.io/hostname y que contienen pods con 
                                           la etiqueta: app: oracle
    topologyKey: kubernetes.io/hostname
    app: oracle

2 Pods (app:oracle)

------
Nodo 1
    NO <  pod 1 oracle
------
Nodo 2
    NO < pod 2 oracle
------


2 pods de oracle
Nodo 1, zona: EU
Nodo 2, zona: EU
Nodo 3, zona: ASIA
Nodo 4, zona: ASIA

Quiero generar antiafinidad con los nodos de las zonas geográficas que ya tengan un pod de oracle

EU
    Nodo 1   oracle pod 1
    Nodo 2
ASIA
    Nodo 3
    Nodo 4  oracle pod 2
    
                podAntiAffinity:
                    requiredDuringSchedulingIgnoredDuringExecution:
                        - topologyKey: zona
                          labelSelector:
                            - matchExpressions:
                                - key: app
                                  operator: In
                                  values:
                                    - oracle
---------

Nodo 1:                           
    WAS
    memcached

Nodo 2:
    WAS
    memcached

Nodo 3: 
    
    
WAS: Antiafinidad pod  topologia a nivel de nodo, No contenga pods con WAS                  
memcached: Antiafinidad pod: topologia a nivel de nodo, No contenga pods con memcached
           Afinidad pod: topologia a nivel de nodo, SI contenga pods con WAS


---------
Hasta hoy tenemos 11 clusters de Kubernetes
----- Lunes
Juntar los nodos en 2 clusters
5 Nodos
5 Nodos 

------------------------------------------------------------------------------------------------------------
                            INGRESS
------------------------------------------------------------------------------------------------------------

Ingress: 
    Qué es? Reglas que configuramos en un INGRESS-CONTROLLER
    Finalidad: Ayudarnos a exponer servicios de tipo CLUSTERIP

IngressController:
    Qué es?   Un programa que corre en un contenedor/pod
              Que tipo de programa: Proxy reverso + BC
    
    NGINX corriendo en un contenedor/pod dentro de kub
        + Servicio (LOAD-BALANCER)


kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.46.0/deploy/static/provider/cloud/deploy.yaml

--- 
NetworkPolicy < Firewall a nivel de RED de kubernetes
Autorización de las comunicaciones
---
Cluster Kub   ---   Lógica   ---    Namespace
    
    Producción
        Oracle: Servicio + Pods
    Preproducción
        Oracle: Servicio + Pods
    Desarrollo
        Oracle: Servicio + Pods
        
Puede uno de los pods de desarrollo, trabajar contra la BBD Oracle de Producción?
    No debería... pero puede?
        Si no configuro nada especial, si, sin problema.
            Que ruta pongo en desarrollo?
                oracle.produccion
                
                
------------------------------------------------------------------------------------------------------
POD WAS > Service Oracle > Pod Oracle
                            Pod Oracle hace Puf
            Redirección de paquetes de red via netFilter
    > Error Not reachable   <     TIMEOUT !     10s ***
    > Error Not available   <     TIMEOUT !     Corto el resto .... encolo el resto
    > Error Not available   <     TIMEOUT !   
    > Error Not available   <     TIMEOUT !     Abro el grifo... cuando llegue el Oracle de vuelta
    > Error Not available   <     TIMEOUT !
    >>>> WAS donde voy a tener un número de Thread en espera wait() 10s
    >>>> El WAS no tiene hilos infinitos. Número de ejecutores
    >>>>>> El WAS se queda sin ejecutores      >>>>>> Todas las peticiones al WAS TIMEOUT
    >>>>>>>>> Incluso cuando se haga por un cliente una petición al WAS que no requiera de BBDD.
        >>>>>>> No va a funcionar... porque no hay ejecutores que la atiendan dentro del WAS
------------------------------------------------------------------------------------------------------

Microservicios

Monto un sistema cuya funcionalidad es ofrecida por un conjunto grande de servicios pequeños


Servicio de Ingreso en CC
Servicio de transferencia
Servicio de Consulta de saldo
Servicio de autenticación

App IVR:    
App cajero: ---> Servicio de autenticacion
                 Transferencia  > Consulta de saldo
Versiones de servicios v1, v2, v3

-------------------------

P1  >     S2    >     P2a-1  |
                      P2a-2  |  0%
                      P2a-3  |
                      --------------
                >     P2b-1  |  100%
                      P2b-2  |  100%
                      P2b-3  |  100%


-----------------------------------------------------------
Cliente    >    BC     >    Cluster     >    Nginx    >     WAS     >      Oracle
                                                    Comunicación interna
httpS: Ayuda a "evitar" (frustrar) 2 tipos de ataques:
    - Man in the middle (sniffer)               <       encriptar los datos
    - Phishing: Suplantación de identidad       <       DNS | proxy reverso 
    
    
    Clave simetrica   Con la misma clave cifro y descifro
    Clave asimetrica  Lo cifrado con una clave requiere otra clave diferente para descifrarse
    
    Clave publica / privada / Certificados firmados por CA

Cual de estas quiero por HTTPS?   TODAS !!!! 
    Voy a necesitar claves publica y privadas para todo perro pichichi
    Voy a necesitar certificados en las mismas cantidades       CADUCAN 1 sem, 1 mes, 3 meses

Desarrollo? NO  
   Comunicaciones < Infraestructura  (Admin Sistemas)
----> 10 minutos
------------------------------------------------------------------------------------------------
ISTIO, LINKERD
------------------------------------------------------------------------------------------------
Contenedor: Estandarizar > Automatización

Comunicaciones

ISTIO: Toma el control de TODAS LAS COMUNICACIONES
Man in the middle
    
    POD                            POD
------------                  --------------                
+ initCont                      + initCont              >>> Generar reglas de netFilter para que toda peticion que se
+                                                           haga a cualquier puerto del pod se pase al envoy
NGINX  Cont       >>>>>         WAS    Cont
Envoy  Cont                     Envoy  Cont           <<<<<     Sidecars

Comparten Conf RED
    IP1                             IP2

El envoy controla TODO:
    Cuando llega o sale una comunicación... PARARLO             <<<<<<      Sustituye a los NetworkPolicy
    Quiero comunicar con el servicio de WAS 
        Backend             Que % mando a cada endpoint
        
    
    

