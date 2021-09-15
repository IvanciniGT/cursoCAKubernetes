Volumenes
    Dónde se declaran los volumenes, a qué nivel? 
        A nivel de POD
    Se montan a nivel de CONTAINER
        
    Dentro de la declaración de un volumen podemos definirlo (decir donde está fisicamente ese volumen).
    Pero esto no es bueno en muchos casos?
        Tienen ciclos de vida diferentes. 
        Son gestionados por perfiles (Administradores vs desarolladores diferentes)
    
    Dónde puedo sacar la definición de un volumen? a que tipo de objeto?    
        PersistentVolume - pv
            Donde está fisicamente el volumen
            Características (tamaño...)
    
    En este escenario cómo se vincula un pv a un pod?
        A traves de un PersistentVolumeClaim - pvc
    
    ¿Quien vincula el pod al pvc? Desarrollador
    ¿Quien vincula el pvc al pv?  kubernetes
    
    En qué casos si que vamos a definir el volumen dentro del pod?
        Cuando vayan a tener el mismo ciclo de vida... Escenarios?
            NO QUEREMOS PERSISTENCIA
        Esto nos da lugar a un tipo de volumen especial:
            emptyDir (puede configurarse con soporte físico en RAM)
        Para qué interesan estos volúmenes?
            Compartir información entre contenedores de un pod
            pruebas
    
--------------------------------------------------------------------------------------

¿Por qué dijimos que nosotros nunca íbamos a definir/crear PODs en kubernetes?
    Perdemos la HA , escalado,...

Quien queremos que lo haga, el crear pods? kubernetes

En base a qué? a plantillas de pods que SI configuramos nosotros

Que objetos permiten a los desarrolladores definir plantillas de pods?
        
                        Cuantos pods crea?                      Persistencia?
    Deployment          Según se solicite (replicas)            Común a todas las replicas
    StatefulSet         Según se solicite (replicas)            Independiente a cada replica
    DeamonSet           Tantas como nodos (auto)
                            en los que se permita instalar

----------------------------------------------------------------------------------------------

Dentro de un POD podemos definir muchos contenedores.
Cómo se ejecutan entre si? 
    Se ejecutan en paralelo entre si
¿Que tipo de procesos/software pueden ejecutar?
    Servicios
    Demonios
    
Los Pods también pueden tener Init Containers. Cuantos? Los que quiera
Cómo se ejecutan entre si? 
    De forma secuencial, ordenados según su declaración en el fichero YAML
Cuando se ejecuta el segundo? 
    Cuando acaba el primero
¿Que tipo de procesos/software pueden ejecutar?
    Scripts

----------------------------------------------------------------------------------------------

Que monitoriza Kubernetes respecto a un POD?
Que siempre se esté ejecutando el QUE?
    El proceso principal (aquel que tiene como id = 1) de cada contenedor del pod
Y muchas más cosas...

-------------------------------------------------------------------------------------------------

Servicio a nivel de kubernetes
    Balanceador de Carga + Nombre DNS + .....
    El nombre del servicio corresponde con el nombre DNS... aunque va cualificado con el NAMESPACE
        DNS: nombre-servicio.nombre-namespace
    Si contactamos sólo usando el nombre del servicio (sin cualificar) a donde vamos?
        Al mismo namespace desde el que hacemos la petición
    Que pasaba con las variables de entorno y los servicios?
        Kubernetes mete variables de entorno con información de los servicios en LOS CONTENEDORES de los PODs.
        Esto es útil? o tiene alguna limitación?
            A medias ....    Solo se hace al crear el contenedor y por tanto los nuevos servicios no estarán 
                             entre las variables de entorno

---------------------------------------------------------------------------------------------------

Servicios:
    Qué es?
        Balanceador de Carga + Nombre DNS + .....
    
    Para que nos sirve un servicio?    
       Ayudarnos a escalar contenedores (Balanceo) 
       Exponer los puertos de aquellos contenedores que me interese exponer. <<<<<<<<<<<<<<<<
    
    Hasta ahora... los servicios que hemos creado solo eran accesibles desde ? El interior de la red del cluster
    
    ?red del cluster? La red virtual que definimos/creamos junto con la creación del cluster.
    
    Qué pasa si queremos que un servicio sea accesible desde fuera del cluster?
        Hay que publicar puertos a nivel del host (esto es lo que hacemos continuamente con DOCKER)
            en kubernetes... de que host? en todos
    
    Cómo se hace eso?
    En kubernetes, los SERVICE, pueden ser de 3 TIPOS:
        ClusterIP
            Generar para el servicio una IP interna al cluster, junto con uno o varios puertos
        NodePort   (más o menos lo que hacemos con Docker)
            Igual que un ClusterIP, pero ADEMAS, se abre en TODOS los HOST (nodos) un puerto en la red PUBLICA de los nodos
        LoadBalancer
            Igual que un NodePort, pero ADEMAS, con un balanceador de carga por delante, externo al cluster
            
            
RED DE MI EMPRESA
| 
|--------- Usuario de mi empresa (IP: 10.0.0.200)  NGINX
|
|--------- DNS Externo   miapp > 10.0.0.250.... ESTO TAMBIEN ME LO COMO YO
|--------- Balanceador de Carga  (IP: 10.0.0.250) <<<< :80 >>>> 10.0.0.100:32080 | 10.0.0.101:32080             Me lo configuro YO *******
|                           
|    Cluster de Kunernetes
|
|=======Nodo 1 (IP: 10.0.0.100)   : 32080 > nginx-service:80
||      |   SO: Linux
||      |       Kernel: NetFilter: Controlar TODO el tráfico de RED
||      |                  ^^       ^^^^
||      |                  ^^     Kubernetes: 20.1.0.100:3306 > 20.0.0.102:3306
||      |                  ^^
||      |       Kernel: IpTables (Definir reglas de red... abrir puertos... cerrar puertos..)
||      |
||      |---POD NGINX-1 (IP: 20.0.0.100)    >>>   mariadb-service (MARIADB IP:20.1.0.100:3306)
||      |                                               ^ Hay que revolver la IP ... quien? CoreDNS (DNS interno de Kubernetes)
||      |
||
|=======Nodo 2 (IP: 10.0.0.101)   : 32080 > nginx-service:80
||      |   SO: Linux
||      |       Kernel: NetFilter: Controlar TODO el tráfico de RED
||      |                  ^^       ^^^^
||      |                  ^^     Kubernetes: 20.1.0.100:3306 > 20.0.0.102:3306
||      |                  ^^
||      |       Kernel: IpTables (Definir reglas de red... abrir puertos... cerrar puertos..)
||      |
|       |---POD NGINX-2 (IP: 20.0.0.101)
|       |
|       |---POD MARIADB (IP: 20.0.0.102:3306)


Servicio mariadb-service a nivel de cluster: IP: 20.1.0.100:3306 > 20.0.0.102:3306
Servicio nginx-service a nivel de cluster:   IP: 20.1.0.101:80   > 20.0.0.100:80 | 20.0.0.101:80
    NodePort: Además monta un puerto [30000-32XXX] en los nodos de kubernetes... en la red "publica"
        LoadBalancer 
            SI y SOLO SI tengo montado un Balanceador de carga Compatible con Kubernetes, Kubernetes va a encargarse de la gestión del balanceador externo *****
            Si trabajo en un Cloud (AWS, Google Cloud, AZURE.... ) Estos clouds ofrecen como producto adicional que puedo adquirir al 
                montar un cluster de Kubernetes basjo sus condiciones y operación, Balanceadores compatibles con Kubernetes
            Si el cluster me lo como yo... es mi cluster... MetalLB



--------------------------------------------------------------------------------

Wordpress
    Apache + php
MariaDB | MySQL

1ª Contenedores? 2
Cuantos Pods?    2
Persistencia?    SI
    Donde?
        BBDD? SI
        Wordpress? SI
Quien va a estar expuesto? WP
---------------------------------

Namespace:     web
Deployment:    Wordpress
StatefulSet:   Mariadb                          ***** Deployment
Service:       MariaDB    ClusterIP : 3306
               Wordpress  NodePort  : 30080:80  *****
PVC            Para los 2
PV             También para los 2            1Gb <<<<<  Simplemente es informativo cuando no usamos un provisionador automático




---------
Deployments: wordpress
    replicas: 3
    nombres tienen los pods?
        wordpress-XXREPLICASET-XXXXX    |
        wordpress-XXREPLICASET-YYYYY    >    BC (service)   <<<< Cliente
        wordpress-XXREPLICASET-ZZZZZ    |

StatefulSet: mariadb
    replicas: 3
    nombres tienen los pods?
        mariadb-0    |
        mariadb-1    >    BC (service:mariadb)   <<<< Cliente      
        mariadb-2    |
    
    Para acceder a un mariadb cualquiera ... el cliente atacaría a?
        mariadb
    Para acceder a un mariadb concreto... el cliente atacaría a?
        mariadb-2.mariadb.namespace
        
        
        mariadb-0
        mariadb-1 PUF
        mariadb-2
        
        mariadb-1

Cada pod tendrá:
    Su propia entrada de DNS
    Su propia Petición de Volumen >>> Su propio Volumen
    
    Vamos a configurar NO UNA PETICION DE VOLUMEN... sino una PLANTILLA DE PETICIONES DE VOLUMEN
    
    Para cada pod se generará SI NO EXISTE YA una pvc cuyo nombre será pvc-NOMBRE-POD
        pvc-mariadb-0
        pvc-mariadb-1
        pvc-mariadb-2


        











    
    
    