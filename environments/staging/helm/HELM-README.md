# environments\staging\helm\HELM-README.md

Create new folder named "helm" in environments\staging\

cd environments/staging/helm

Execute bellow command to create s scaffold helmm deployment structure: 
```
helm create nginx-server
```

Need only bellow files in templates folder:
```
deployment.yaml
service.yaml
ingress.yaml
_helpers.tpl
```

Delete the rest

To check exact chart version:
```
helm show chart ./nginx-server
```
Output:
```
apiVersion: v2
appVersion: 1.29.2
description: Simple NGINX server with Ingress for EKS/ALB demo
name: nginx-server
type: application
version: 0.1.0
```



Check if templates are OK - Try with:
``` 
helm lint ./nginx-server
```
Output:
```
==> Linting ./nginx-server
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```


To render the generated temlplates execute:
```
helm template nginx-server ./nginx-server -f ./nginx-server/values.yaml
```

Output:
```
---
# Source: nginx-server/templates/service.yaml   
apiVersion: v1
kind: Service
metadata:
  name: nginx-server
  labels:
    helm.sh/chart: nginx-server-0.1.0
    app.kubernetes.io/name: nginx-server        
    app.kubernetes.io/instance: nginx-server    
    app.kubernetes.io/version: "1.25.3"
    app.kubernetes.io/managed-by: Helm
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 80
  selector:
    app: nginx-server
---
# Source: nginx-server/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-server
  labels:
    helm.sh/chart: nginx-server-0.1.0
    app.kubernetes.io/name: nginx-server
    app.kubernetes.io/instance: nginx-server
    app.kubernetes.io/version: "1.25.3"
    app.kubernetes.io/managed-by: Helm
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-server
  template:
    metadata:
      labels:
        app: nginx-server
    spec:
      containers:
        - name: nginx
          image: "nginx:latest"
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
---
# Source: nginx-server/templates/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-server
  annotations:
    alb.ingress.kubernetes.io/scheme:
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
    alb.ingress.kubernetes.io/healthcheck-path: /
    nginx.ingress.kubernetes.io/rewrite-target: "/"
spec:
  ingressClassName: nginx
  rules:
    - host:
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-server
                port:
                  number: 80
```

Redirect it to a file if you want to include it in a report:
```
helm template nginx-server ./nginx-server -f ./nginx-server/values.yaml > rendered.yaml
```





helm install nginx-server ./nginx-server -n webapps --create-namespace --dry-run --debug



helm install nginx-server ./nginx-server -n webapps --create-namespace
