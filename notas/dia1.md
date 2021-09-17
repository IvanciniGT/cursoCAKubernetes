Kubernetes
------------


Contenedor:
    Dentro de un SO... Microservicio AISLADO dentro de un SO
    Donde corre un servicio o un demonio..... 

    Entorno AISLADO donde ejecutar PROCESOS dentro de un SO LINUX

    PROCESOS:
        Servicios - Puerto
            Apache:
                Proceso maestro
                Subprocesos workers
        Demonios
        Scripts
    
    Entorno AISLADO... en cuanto a qué?
        FileSystem          ------        chroot
        Configuración de RED
        Limitación de recursos HW
            CPU, RAM
        Variables de entorno (SO)
            Variables para ser utilizadas por PROCESOS, que son gestionadas por el SO.
                HOST       ps -af    <<< veremos todos los procesos que tenga corriendo en el host y en contenedores

                Politicas de acceso... <<<<<<

    FileSystem de un contenedor:
        Capas superpuestas
            Base: Imagen de Contenedor <<<< Es editable? NO ES EDITABLE
            Capa a nivel del Contenedor  << Su ciclo de vida va asociado al contenedor... SI ES EDITABLE

    Dentro de un contenedor hay un SO? NO
        Los procesos que corren dentro de un Contenedor interactuan con el KERNEL del LINUX instalado en el HOST
        Lo minimo?
    Estructura de carpetas equivalentes a un SO Linux

    Imagen de Contenedor?
        De forma comprimida nos da: Colección de archivos y carpetas
        Configuraciones por defecto....

    SO LINUX: 
        /
        /home
        /bin
        /sbin
        /opt
        /var
        /var/lib/docker/
                        images
                              /apache/                           <<<<<<< CARPETA BASE DEL FS DEL CONTENEDOR. NO SE PUEDE MODIFICAR
                                      bin
                                      etc/
                                            apache/
                                                    httpd.conf
                                      var
                                      opt
                                            apache/
                                                    httpd     <<<<< BINARIO
                                      home
                        containers
                                    /mi_contenedor_apache/
                                                            etc/
                                                                apache/
                                                                        httpd.conf   <<<<< EDITADO
        /logs

    Desde dentro de un Contenedor... miro su filesystem: ls /
                VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                            var                                                         <<<<<<< VOLUMEN > ¿Donde va a tener su persistencia real?
                                                log                                                                             No se... en el host... o nfs... cloud
                                                    apache.log                                                  EDITABLE... ES PERSISTENTE TRAS LA MUERTE DEL CONTENEDOR
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                        etc                                                                             <<<<<<< A NIVEL DEL CONTENEDOR     EDITABLE.... EFIMERA
                            apache              
                                httpd.conf          
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        bin             etc                 var         opt                      home                   <<<<<<< IMAGEN DEL CONTENEDOR      INALTERABLE
                            apache                          apache
                                httpd.conf                      httpd
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Borrado de contenedors:
    - Escalado de nuestras apps
    - Pruebas
    - Mover contenedor entre máquinas: Borrado y creación de un nuevo contenedor
    - Actualización
    - Reconfiguración

MariaDB 10 > 11


Configuración de RED
Redireccion de puertos a nivel de HOST... para poder comunicarnos con un servicio que se ejecuta dentro del contenedor
Los contenedores tiene una red de contenedores


Qué es una interfaz de red?
    Se monta a nivel de SO
    A través de lo que me comunico con una red ( a nivel lógico de software)   
                                                A nivel de HW: NIC... tarjeta de red

Cuántas interfaces de red tenemos normalmente en un SO.... Windows. Linux?
    Interfaz de RED asociada a una NIC.... Nuestra tarjeta de WIFI, ETHERNET
        192.168.1.134
    LOOPBACK   <<<< A que tarjeta/RED física está vinculado esta interfaz de red? A ninguna
                    Está vinculada a una red virtual... y que solo vive dentro del host
        127.0.0.1 - localhost
    DOCKER
        172.17.0.1

Cuando trabajamos con contenedores ... creamos interfaces de RED adicionales que trabajan sobre redes virtuales NUEVAS

    Si creamos el contenedor de APACHE.... <<<<<  Se conecta a la red virtual de DOCKER...... 172.17.0.2
            httpd          172.17.0.2:80
    
    ¿Quién puede acceder a 172.17.0.2:80?
        Cualquiera que esté pinchado en la misma red (segmento)
        Mi host puede acceder? SI
        Alguien externo al HOST puede acceder? NO... ya que la red de DOCKER es INTERNA AL HOST
            NAT: Redirección de puertos:      192.168.1.134:80 > 172.17.0.2:80


-------------------------------------------------------------------------------------------------------------------------

Entorno de producción? Donde están las apps que están en servicio real de cara a los usuarios.
¿Qué características diferenciadoras tiene un entorno de producción?
    Alta disponibilidad <<< Tiempo de servicio: 99%..... 99.9%          99.99%         APUESTA A FUTURO         De que depende el poner más 9?  PASTA
    Escalabilidad ?   Capacidad de adaptar nuestros recursos a las necesidades puntuales reales     <<<<<<<<<<                                  PASTA

    SEGURO? SI... como cualquiera

Cluster? Agrupación

Que necesito cuando trabajo con una app instalada en un cluster: BALANCEADOR DE CARGA... Es quien recibe las peticiones y las manda a UNA de las apps instaladas en el cluster

Maquina 1
    App1
Maquina 2     PUF !!!!!!
    App1
Maquina 3
    App1
Maquina 4               <<<< Quito
    App1
Maquina 5               <<<< Quito
    App1

BALANCEADOR DE CARGA? 
    F5
    nginx *          Proxy reverso con capacidad de balanceo de carga
    apache

Kubernetes / Openshift

Qué es Openshift? Una distro de kubernetes que fabrica REDHAT

Kubernetes?
    Es un gestor de gestores de contenedores instalados en un cluster de máquinas

Kubernetes es una herramienta que me permitirá controlar los dockers que tengo instalados en una máquinas de un cluster
    Maquina 1
        Docker 
            C1
            C2
    Maquina 2
        Docker
            C3
    Maquina 3
        Docker
            C4
            C5
            C6

Instalar un app en un entorno de producción:
    Hacer las instalaciones.... en cada nodo del cluster
    Montar un BC que de acceso a esas instalaciones
    Esas instalaciones las tendré que monitorizar:
        Alta disponibilidad
        Escalabilidad
            Encender / apacgar instalaciones... o hacer nuevas....

    KUBERNETES ME PERMITE AUTOMATIZA EL PROCESO DE DESPLIEGUE + MONITORIZACION + OPERACION de apps en un cluster
        Además ejecutándose en entornos AISLADOS

Que vamos a hacer para instalar Kubernetes?
Instalar algo(S) en todos los hosts:
    - Un gestor de contenedores: docker, crio, containerd
    - Un agente... cuya misión: recibir las ordenes de api-server... y hablar con los docker o similares
        kubelet (servicio)
    - Un agente que conecte y gestione las conexiones a esa red:
        kubeproxy
    - kubeadm: Permite operaciones de gestión del cluster: Añadir maquinas, quitar máquinas de un cluster
Balanceadores de carga
RED VIRTUAL a nivel de cluster: Quién define y controla la red

Voy a necesitar montar en algún sitio: corazón de KUBERNETES
Aqui tendremos un monton de programas, que van a estar ejecutándose en CONTENEDORES que están diseminados por el propio cluster:
    api-server
    scheduller: Cuya misión: Planificar donde se van a desplegar los contenedores
    manager
    etcd:       BBDD clave - valor
    core-dns

Kubernetes no es un programa... si no un conjunto de ellos... que todos trabajando juntos consiguen ayudarme a gestionar un entorno de producción absado en Contenedores

Cómo nos comunicamos con KUBERNETES (api-server)
    A través de una herramienta cliente: kubectl   <<<<<<<<<<<<<< QUEREMOS CONTROLAR EL CLUSTER A TRAVES DEL CLI   <<<<<<<<<<<<<<<<<<<   scripts: AUTOMATIZAR
                                         oc
    A través de un entorno gráfico:      dashboard de kubernetes : UI tipo WEB oficial (que no se instala por defecto)
                                         dashboard de Openshift

---------------------------------------------------------------------------------------------------------
Dentro de Kubernetes tendremos distintos tipos de OBJETOS/COSAS que podemos configurar:
    Contenedores < NOP !!!! Kubernetes no permite configurar ni trabajar directamente con CONTENEDORES
    POD: Qué es esto?
            Conjunto de contenedores que:
                Comparten: 
                    Configuración de red y dirección IP
                    Tengo asegurado que se desplegarán en la misma maquina (host)
                    Van a escalar de la misma forma
                    NO REALIZAN LA MISMA FUNCION
        Pensais que nosotros vamos a crear muchos pods dentro de kubernetes? NO. ni uno
                    se van a                                               ? SI... quien los va a crear? KUBERNETES
        Qué voy a crear yo? Plantillas de PODS
    Configuraciones para crear pods desde plantillas:
        DEPLOYMENTS
        STATEFULSETS
        DAEMONSET

    Cuando cremos una plantilla de POD y pida a kubernetes que quiero 5 copias de esa plantilla... esto es 5 PODS... para dar un servicio
        SERVICE: Balanceador de carga + nombre DNS
    
    VOLUMES
    CONFIGMAPS
    SECRETS

    Usuarios?
        SERVICEACCOUNT

Cada uno de estos objetos que vamos a dar de alta en Kubernetes... lo definiremos en un fichero YAML


Docker:
    ballena(barco de carga) con "contenedores"
Kubernetes:
    timon





Docker-compose es una herramienta que permite gestionar y ejecutar apps multicontenedor, definidas en ficheros YAML


--------

Un documento YAML de kubernetes va a tener siempre:

kind:     EXPRESA EL TIPO DE OBJETO QUE VOY A CREAR EN KUBERNETES
      Pod, Service, DaemonSet, Configmap
apiVersion: v1
            apps/v1
            openshift/v1
La version de la libreria que contiene la definición de ese tipo de objeto que voy a crear
metadata:
    name: IDENTIFICADOR DEL OBJETO QUE CREO

spec:


-----------
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
