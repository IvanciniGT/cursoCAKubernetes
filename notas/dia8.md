Produccion
Pre-produccion (Integracion/QA)
Desarrollo


Produccion=Pre-produccion <  Deben ser Iguales

QA
 ^^^
Dessarrollo


Prod - Pre   <    dns



Desarrollo: Portatil
2 Supuestos:
    1 - Cloud externo
    2 - On premisses
            - LoadBalancer
            - Ingress < Ingress Controller
                - ClusterIP
                
            - NodePort
            
    Para poder disfrutar de un Load Balancer:
        - MetalLB
        - IngressController
        - DNS externo < nombres de dominio
        