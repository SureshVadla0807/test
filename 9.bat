
@echo off
setlocal
title Experiment 9 - Kubernetes Automation

echo ==========================================
echo   Experiment 9: Kubernetes Automation
echo ==========================================

echo.
echo [1] Checking Kubernetes...
kubectl get nodes
if errorlevel 1 goto :error

echo.
echo [2] Checking Docker image...
docker image inspect docker-k8s-app:1.0 >nul 2>&1
if errorlevel 1 (
    echo ERROR: Image docker-k8s-app:1.0 not found.
    echo Run Exercise 8 first.
    goto :error
)

echo.
echo [3] Creating project folder...
mkdir Experiment9 2>nul
cd /d "%~dp0Experiment9"
if errorlevel 1 goto :error

echo.
echo [4] Creating Deployment YAML...
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
) > deployment.yaml

echo.
echo [5] Creating Service YAML...
(
echo apiVersion: v1
echo kind: Service
echo metadata:
echo   name: web-service
echo spec:
echo   type: ClusterIP
echo   selector:
echo     app: web
echo   ports:
echo   - port: 80
echo     targetPort: 80
) > service.yaml

echo.
echo [6] Deploying application...
kubectl apply -f deployment.yaml
if errorlevel 1 goto :error

kubectl apply -f service.yaml
if errorlevel 1 goto :error

echo.
echo [7] Waiting for application...
kubectl rollout status deployment/web-deployment --timeout=120s
if errorlevel 1 goto :error

echo.
echo [8] Initial deployment status...
kubectl get deployments
kubectl get pods

echo.
echo [9] Demonstrating self-healing...
for /f "delims=" %%P in ('kubectl get pods -l app=web -o name') do (
    kubectl delete %%P
    goto :healing
)

:healing
echo Waiting for Kubernetes to restore replicas...
timeout /t 8 /nobreak >nul
kubectl get pods

echo.
echo [10] Scaling to three replicas...
kubectl scale deployment web-deployment --replicas=3
if errorlevel 1 goto :error

kubectl rollout status deployment/web-deployment --timeout=120s
if errorlevel 1 goto :error

echo.
echo [11] Final status...
kubectl get deployments
kubectl get pods
kubectl get services

echo.
echo [12] Starting port forwarding...

REM Reuse an existing port forward if one is already active.
powershell -NoProfile -Command ^
 "$c=Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue; foreach($x in $c) { $p=Get-CimInstance Win32_Process -Filter ('ProcessId='+$x.OwningProcess); if($p -and $p.CommandLine -match 'kubectl.*port-forward.*8080:80') { exit 0 } }; exit 1" >nul 2>&1

if not errorlevel 1 goto :openbrowser

start "Kubernetes Port Forward" cmd /k "kubectl port-forward service/web-service 8080:80"

echo Waiting for port forwarding...
timeout /t 5 /nobreak >nul

:openbrowser
echo.
echo Opening application...
start "" http://localhost:8080

echo.
echo ==========================================
echo SUCCESS: Kubernetes automation completed.
echo Application: http://localhost:8080
echo ==========================================
echo.
echo Keep the port-forward CMD window open.
echo.
echo To remove Kubernetes resources:
echo kubectl delete -f deployment.yaml
echo kubectl delete -f service.yaml
echo.
pause
exit /b 0

:error
echo.
echo ERROR: An operation failed.
echo Check Docker Desktop, Kubernetes and Pod status.
pause
exit /b 1
