
kubectl [verbo] [tipo de objeto] [modificadores]
    
    verbos:
        - get
        - describe
        - delete
    
    objetos:
        - nodes
        - pods
        - namespaces
        - services
        - all
        
    modificadores:
        - -n, --namespace
        - --all-namespaces
        - -o wide

kubectl apply -f [FICHERO]



docker exec [-it] nombre_contenedor COMANDO
kubectl exec [-it] NOMBRE_POD -c NOMBRE_CONTENEDOR -- COMANDO

docker logs NOMBRE_CONTENEDOR
kubectl logs NOMBRE_POD -c NOMBRE_CONTENEDOR





