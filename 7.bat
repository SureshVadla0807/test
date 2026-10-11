
@echo off
title Docker Containerized Application

echo ===== Creating Project =====
mkdir DockerApp 2>nul
cd /d "%~dp0DockerApp"
mkdir app 2>nul

echo Creating HTML application...
(
echo ^<!DOCTYPE html^>
echo ^<html^>
echo ^<head^>
echo ^<title^>Docker Application^</title^>
echo ^</head^>
echo ^<body^>
echo ^<h1^>Hello from Docker!^</h1^>
echo ^<p^>Application running successfully.^</p^>
echo ^</body^>
echo ^</html^>
) > app\index.html

echo Creating Dockerfile...
(
echo FROM nginx:alpine
echo COPY app/index.html /usr/share/nginx/html/index.html
echo EXPOSE 80
) > Dockerfile

echo Checking Docker...
docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Start Docker Desktop first.
    pause
    exit /b 1
)

echo Building Docker image...
docker build -t simple-web-app .

if errorlevel 1 (
    echo Image build failed.
    pause
    exit /b 1
)

echo Starting container...
docker rm -f simple-web-container >nul 2>&1
docker run -d --name simple-web-container -p 8080:80 simple-web-app

if errorlevel 1 (
    echo Container failed to start.
    pause
    exit /b 1
)

echo Checking running container...
docker ps

echo Opening application...
start "" http://localhost:8080

echo.
echo SUCCESS!
echo Application: http://localhost:8080
echo Stop container: docker stop simple-web-container
echo Remove container: docker rm -f simple-web-container
pause
