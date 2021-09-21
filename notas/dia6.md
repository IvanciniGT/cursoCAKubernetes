Alfred
-----------------
Antoni
David
Florian             
Fabio           *****
Ismael
----------------
Javier
JoseAngel       *****
JoseCarlos             <<<<<<<<<<<<<<
JoseIsmael             <<<<<<<<<<<<<<
Sergi
----------------
        STATEFULSET
    Nodos Maestros - 3 QUORUM....... 2 Maestros (Activo-Pasivo) + 1 maestro de mentirijilla
    Nodos Data - Almacenar datos y hacer busquedas - 2
    Nodos ingesta        >>>> Carga de datos - 1
    Nodos coordinadores  <<<< Conectan con los clientes (QUERY) - 1
    
        DEPLOYMENT
    Cerebro y Kibana
    
    Deployments / Statefulset** <<<< Plantillas de pods + replicacion
    
    
    stack elk
    
    
-----------------
Instalación básica de Kubernetes
--------
Maestro
    Nodo 1
    Nodo 2
    Nodo 3

PCs de los administradores
    kubectl
        config -> ~/.kube





ElasticSearch   <<<<<<<<<<    KIBANA
    Recolector de logs .... RUINA GRANDE !
    
Motor de Indexación y búsquedas <                Google

Beats < FileBeat, HeartBeat, MetricBeat
Fluentd

-----> Logstash | Kafka


ES -> Motor de indexación DISTRIBUIDO
    Va a trabajar en un cluster de nodos de ES

ES:
    Nodos Maestros - 3 QUORUM....... 2 Maestros (Activo-Pasivo) + 1 maestro de mentirijilla
    Nodos Data - Almacenar datos y hacer busquedas - 2
    Nodos ingesta        >>>> Carga de datos - 1
    Nodos coordinadores  <<<< Conectan con los clientes (QUERY) - 1
    Cerebro y Kibana
    
    
    
-----------------------------
Producción < Pre < Desarrollo

YAML <<<<<< 1 unico YAML

Varios YAML en funcion del entorno <<<<< Config Map, Secrets, Volumenes, RAM,....
    YAML -> Chart HELM - Plantilla

Instalación base ... La vamos a borrar
ISTIO < ES sobre ISTIO


Stack ELK
Logstash > ElasticSearch <<< Kibana
                ^^^^^
                6 nodos
                2 maestros
                2 de datos
                1 ingesta1 coordinador
                
                
            Master1    Master2*  (^)
                |            |
Data1 --------------------------------- Data2 (X)
               |             |
            Ingesta(^)     Coordinacion (^)
              ^                ^
            Logstash        Kibana
            
            
            Usuario final ELK
            Usuario final de ElaticSearch <<<< Kibana <<<< Persona
    
Las comunicaciones de formación de cluster en ES son UNICAST


Ingesta > maestro? a cual? lo mismo da < SERVICIO MAESTROS: BC Nodos maestro
Coordinacion > maestro? a cual? lo mismo da < SERVICIO MAESTROS: BC Nodos maestro
Datos > maestro? a cual? lo mismo da < SERVICIO MAESTROS: BC Nodos maestro
----------- NO
Maestros > maestro? a cual? lo mismo da < SERVICIO MAESTROS: BC Nodos maestro
Maestro1 > SERVICIO MAESTROS: BC Nodos maestro (Maestro 1)   <<<<<<<<<<<<<<<<< EXPLOSION . NO HAY CLUSTER
Maestro1 > maestro1? NO      maestro2
Maestro2 > maestro2? NO      maestro1



Maestro0 - M1, M2, M3, M20
Maestro1 - M0, M2, M3
Maestro2 - M0, M1, M3
Maestro3 - M0, M1, M2

Maestro20 - M0, M1, M2, M3


9200 < Comunicaciones con clientes < Ingesta, Corrdinador, DataX, Maestro Servicio: 9200
9300 < Comunicaciones internas entre los nodos


cluster de Kubernetes
    Nodo 1K - VM - Labels
        Nodo 1ES
        Nodo 2ES
    Nodo 2K - VM - Labels
        Nodo 3ES
        Nodo 4ES
    Nodo 3K
        Oracle que se lleva muy muy muy muy mal con esa configuracion
    ...
    Nodo NK