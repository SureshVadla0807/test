
@echo off
setlocal
title Experiment 8 - Docker and Kubernetes

echo ==========================================
echo  Experiment 8: Integrate Docker and K8s
echo ==========================================

echo.
echo [1] Checking Docker...
docker --version
if errorlevel 1 goto :error

docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Start Docker Desktop first.
    goto :error
)

echo.
echo [2] Checking Kubernetes...
kubectl version --client
if errorlevel 1 goto :error

kubectl get nodes
if errorlevel 1 (
    echo ERROR: Enable Kubernetes in Docker Desktop.
    goto :error
)

echo.
echo [3] Creating project structure...
mkdir DockerK8sApp 2>nul
cd /d "%~dp0DockerK8sApp"
if errorlevel 1 goto :error

mkdir k8s 2>nul

echo.
echo [4] Creating index.html...
(
echo ^<!DOCTYPE html^>
echo ^<html^>
echo ^<head^>
echo ^<meta charset="UTF-8"^>
echo ^<meta name="viewport" content="width=device-width, initial-scale=1"^>
echo ^<title^>Docker and Kubernetes^</title^>
echo ^<style^>
echo body { font-family: Arial; text-align: center; margin-top: 100px; background: #eef2ff; }
echo h1 { color: #3730a3; }
echo ^</style^>
echo ^</head^>
echo ^<body^>
echo ^<h1^>Hello from Docker and Kubernetes!^</h1^>
echo ^<p^>Application deployed successfully.^</p^>
echo ^<p^>Two replicas managed by Kubernetes.^</p^>
echo ^</body^>
echo ^</html^>
) > index.html

echo.
echo [5] Creating Dockerfile...
(
echo FROM nginx:alpine
echo COPY index.html /usr/share/nginx/html/index.html
echo EXPOSE 80
) > Dockerfile

echo.
echo [6] Building Docker image...
docker build -t docker-k8s-app:1.0 .
if errorlevel 1 goto :error

echo.
echo [7] Creating Kubernetes Deployment...
(
echo apiVersion: apps/v1
echo kind: Deployment
echo metadata:
echo   name: web-deployment
echo spec:
echo   replicas: 2
echo   selector:
echo     matchLabels:
echo       app: web
echo   template:
echo     metadata:
echo       labels:
echo         app: web
echo     spec:
echo       containers:
echo       - name: web
echo         image: docker-k8s-app:1.0
echo         imagePullPolicy: IfNotPresent
echo         ports:
echo         - containerPort: 80
) > k8s\deployment.yaml

echo.
echo [8] Creating Kubernetes Service...
(
echo apiVersion: v1
echo kind: Service
echo metadata:
echo   name: web-service
echo spec:
echo   type: NodePort
echo   selector:
echo     app: web
echo   ports:
echo   - port: 80
echo     targetPort: 80
echo     nodePort: 30080
) > k8s\service.yaml

echo.
echo [9] Deploying application...
kubectl apply -f k8s\deployment.yaml
if errorlevel 1 goto :error

kubectl apply -f k8s\service.yaml
if errorlevel 1 goto :error

echo.
echo [10] Waiting for deployment...
kubectl rollout status deployment/web-deployment --timeout=120s
if errorlevel 1 goto :error

echo.
echo [11] Checking deployment status...
kubectl get nodes
kubectl get deployments
kubectl get pods
kubectl get services

echo.
echo [12] Starting port forwarding...

REM Stop an old port-forward process if one is listening on port 8080.
REM This does not terminate unrelated applications.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$c=Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue; foreach($x in $c) { $p=Get-CimInstance Win32_Process -Filter ('ProcessId='+$x.OwningProcess); if($p -and $p.CommandLine -match 'kubectl.*port-forward') { Stop-Process -Id $x.OwningProcess -Force -ErrorAction SilentlyContinue } }"

start "Kubernetes Port Forward" cmd /k "kubectl port-forward service/web-service 8080:80"

echo Waiting for port forwarding to start...
timeout /t 4 /nobreak >nul

echo.
echo [13] Testing application...
curl --max-time 5 -s http://localhost:8080
if errorlevel 1 (
    echo.
    echo Port forwarding may still be starting.
    echo Check the separate port-forward CMD window.
    echo Then open http://localhost:8080 manually.
) else (
    echo.
    echo Application is responding.
    start "" http://localhost:8080
)

echo.
echo ==========================================
echo Deployment setup completed.
echo URL: http://localhost:8080
echo ==========================================
echo.
echo To stop port forwarding, close its CMD window.
echo To remove Kubernetes resources:
echo kubectl delete -f k8s
echo.
pause
exit /b 0

:error
echo.
echo ERROR: Setup failed.
echo Check Docker Desktop, Kubernetes and CMD output.
pause
exit /b 1
