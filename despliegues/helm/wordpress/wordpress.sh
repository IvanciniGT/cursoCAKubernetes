cat <<EOF | kubectl apply -f -
apiVersion:     v1
kind:           Namespace
metadata:
  name:         wordpress
EOF

cat <<EOF | kubectl apply -f -
apiVersion:     v1
kind:           Secret
metadata:
  name:         mi-wordpress
  namespace:    wordpress
data:
    wordpress-password: cGFzc3dvcmQ=
EOF

cat <<EOF | kubectl apply -f -
# Desarrollador
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
    name: peticion-volumen-wp
    namespace:    wordpress
spec:
    resources:
        requests:
            storage: 1Gi
    accessModes:
        - ReadWriteOnce 
    storageClassName: volumen-nfs
EOF

cat <<EOF | kubectl apply -f -
# Desarrollador
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
    name: peticion-volumen-wp-db
    namespace:    wordpress
spec:
    resources:
        requests:
            storage: 1Gi
    accessModes:
        - ReadWriteOnce 
    storageClassName: volumen-nfs
EOF


helm repo add bitnami https://charts.bitnami.com/bitnami

helm install mi-wordpress bitnami/wordpress \
    -n wordpress \
    -f wordpress.values.yaml