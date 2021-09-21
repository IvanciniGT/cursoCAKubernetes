
Desarrollador
    Sus apps tienen que estar preparadas para ejecutarse dentro de contenedores:
        - Tienen que tener muy claro donde se guardan datos en ficheros < Volumenes
        - Tienen que poner las opciones de configuración de su app desde variables de entorno < Env
        - Los puerto donde todo va a funcionar
        ----> Imagen de contenedor
            ---> YAML Kubernetes -> Chart Helm
Infra/Kubernetes
    ---> Instalar y administrar un cluster de Kubernetes
        ---> Volumenes
    ---> Despliegues con Helm
    ---> Conocedores de todos los objetos que va creando un desarrollador
        -> logs, pvc deployment replicas 
        ---> HPA
Seguridad/Redes
    ---> NetworkPolicies
    ---> Secrets
DBA
    ---> ConfigMap BBDD
Monitorización