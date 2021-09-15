Contenedor:
 Se ejecutan de forma indefinida en el tiempo:
     - Servicios       Abre puerto donde atiende peticiones
     - Demonios        El se ejecuta y sabe que hacer si que nadie diga nada
 Se ejecuta de forma finita en el tiempo
     - Scripts   
  
En kubernetes:
   Se ejecutan de forma indefinida en el tiempo:
     - Servicios       Abre puerto donde atiende peticiones
     - Demonios        El se ejecuta y sabe que hacer si que nadie diga nada


En un pod podemos tener varios contenedores.
Cómo comunico esos contenedores entre si:
    - Pueden comunicarse mediante: localhost:PUERTO
    - A través del sistema de archivos? REALLY?
        Tienen el mismo FS? NO
        Lo que podemos es montar a todos el mismo volumen
                            mount

Los volumenes se definen a nivel de POD.

Para que sirven los volumenes?
    - Guardar la información de forma persistente
    - Compartir la información
        - Entre contenedores
            - Características:
                Me importa donde se guarde?
                    SI - Quiera compartir información a futuro
                         PERSISTENCIA
                    NO - No quiero compartirla a futuro
                         Si los contenedores están en pods independientes
                            En un recurso compartido en red
                         Si los contenedores están en el mismo pod
                            Me interesa un volumen en local
                                EMPTY_DIR
        - Entre contenedor y host
        
emptyDir: Tipo de volumen que genera una carpeta dentro del host (en un lugar "desconocido")
          La carpeta se genera vacia
          Es equivalente en funcionamiento a la CAPA a nivel de CONTENEDOR del FS de DOCKER

            USO: Was, Websphere/liberty/ apache > LOGS ACCESO
            Quiero un programa que vaya monitorizando los logs > ES
            
            Configuracion:
                medium: Memory

hostPath: Crea o comparte un archivo o carpeta entre host y contenedor

            USO: Pruebas
            Acceder a datos del host
            
            No sirve realmente para persistencia
            
            Configuracion:
                path: RUTA DEL ARCHIVO O CARPETA EN HOST
                type: Directory
                      File
                      DirectoryOrCreate
                      FileOrCreate

 
Para personalizar un contenedor?
    Inyectar ficheros de configuracion mediante volumenes
    Variables de entorno

MariaDB
    NAMESPACE: basedatos
    POD:
        Contenedor: Imagen MariaDB
                        Configurarlo
                    Persistencia < Volumen (hostPath)
    SERVICIO
        Puerto
    
ALGUIEN QUE LLAME AL MARIADB >>> SERVICIO >>> MARIADB


Objetos en Kubernetes con/sin Namespace

    CON NAMESPACE                           SIN NAMESPACE   
        pod                                     node
        service                                 namespace
        configMap
        secret
        persistentVolumeClaim                   persistentvolume
        
        
Cosas a resolver:
    Passwords...
    Volumen...
    Variables de Configuración de Entorno...
    Servicio...
    Ciclo de Vida de la BBDD POD?
    
Volumen: ????
    Tipo.... raro... hostPath no es adecuado
    Quién ha escrito este fichero?
        Desarrollador
    Es responsabilidad del desarrollador decidir donde se guardan los datos?
        NO
    Entre entorno (pre, pro... ) se guarda en el mismo sitio?
        NO
        
YAML
    Objetos
    Quien define cada objeto
        POD       << Desarrollador
            Configuración
            Donde se guardan los datos
        CONFIGMAP << Administrador
        SECRET    << Administrador
        PERSISTENT_VOLUME            << Administrador
        PERSISTENT_VOLUME_CLAIM      << Desarrollador


Pod: (desarrollador)
    Usa un Volumen... Tendré algo que decir respecto al volumen?
        Rendimiento      ALTO
        Tamaño           50Gbs
        Replicación      SI   RAID ESPEJO
        Encripción       NO

Quien define el volumen: Administrador: PersistentVolume


Gi - Gibibyte: 1024 Mbi - 1024*1024 Kbi - 1024x1024x1024 b
Gb - Gigabyte: 1000 Mb


        VAN ASOCIADAS A NAMESPACE       NO VAN ASOCIADOS A NS
 D                  D                            Ad
POD <> Peticion de Volumen Persistente <> Volumen Persistente
                                        |                        Porque cada objeto es creado por un perfil
     |                                                           Porque la petición de volumen y el pod tienen vidas independientes

POD: mariadb ...... Este pod es ETERNO? NO... morirá... cuando? 
        - Porque no haga falta más
        - Porque se cruje
        - Porque actualice a una nueva versión de mariadb
        - Porque se mueva de máquina
    Volumen:    la peticion 17
        
peticion 17:
    2 Gbs     RAPIDITO

Catalogo Volumenes:
    Volumen 1    10 Gb    RAPIDITO       AWS
    volumen 2     5 Gb    LENTITO        NFS
    Volumen 3     1 Gb    REPLICACION    CABINA EMC2
    
POD: MARIADB-POD-3     <>      Petición 17      <>      Volumen 1

Petición 17      <>      Volumen 1
    Es establecida por Kubernetes... en base a: 
        - Tamaño
        - AccessMode
        - StorageClass
    Cuando? 
        Cuando se crea quien? La petición

MARIADB-POD-3     <>      Petición 17 
    Es establecida por ? Desarrollador explicitamente
    Cuando? Cuando defino el POD
    
PeticionDatosMariaDB <> Volumen187    <<<<<<<<<<<<<< Trasciende al borrado de un POD
MARIADB-version10 <> PeticionDatosMariaDB
    MARIADB-version10 <> Volumen187 *************** LA IMPORTANTE

DELETE POD... pero al borrar el pod, ni se borra la peticion, ni el volumen, 
    ni la relación entre ellos
    
MARIADB-version11 <> PeticionDatosMariaDB
    MARIADB-version11 <> Volumen187 *************** LA IMPORTANTE
    
    
Cómo se generan los VOLUMENES PERSISTENTES EN LA PRACTICA, en el dia a dia 
    Tarea del administrador
    3 opciones:
        - Bajo demanda. Adhoc para una "pvc" genero un "pv"  +++ Optimización de espacio
                                                             --- Latencia... retraso
        - Precreación de volumenes... Tengo 50 precreados    +++ Inmediatez
                                                             --- Tengo mucho espacio prereservado sin uso
        - Provisionador automático de volumenes             <<<< GUAY      
                                                             +++ Inmediatez
                                                             +++ Optimización de espacio
            Cuando se haga un pcv por un desarrollador
                En automático kubernetes genera el pv
            Esto requiere un nuevo tipo de objeto en Kubernetes
            
                StorageClass + Provisioner
                    NFS Provisioner
                        Servidor de NFS *
                        


ResourceQuota
LimitRanges


DEPLOYMENT:
    Plantilla de pods de la que quiero un número inicial de replicas en funcionamiento
STAFULSET:
    Plantilla de pods + Pkantilla de pvcs de la que quiero un número inicial de replicas en funcionamiento
        pero... quiero... nombres de pods que no sean aleatorios y además
            quiero que cada pod tenga sus propias peticiones de volumen
DAEMONSET:    
    Plantilla de pods de la que ya se cuantas replicas en funcionamiento quiero... tantas como nodos
    
    
Un deployment siempre lleva asociado un replicaset
Replicaset:
    Un programa dentro de kubernetes que segura que siempre tengo el numero deseado de pods
    
    
    MariaDB1    >>>>>   ficheros datos   <<<<<<< MariaDB2      PLOSSS !!!!!
    
    
    
WORDPRESS (CRM)  10 replicas + BALANCEADOR DE CARGA
    Cargo con una página WEB (VOLUMEN)

Quiero los 10 nginx trabajando sobre el mismo volumen? o sobre volumenes diferentes?
    Mismo?
    
Cliente ----BC   -----  WP1
                 \----  WP2* Sube fichero PDF
Cliente2          \---  WP3 ** 

Cluster MariaDBs
    MariaDB1 --- Aquí habrá unos datos
    MariaDB2 --- Aquí hay otra parte de los datos
    MariaDB3 --- Aquí otros
