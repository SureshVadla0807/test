
@echo off
title Git and GitHub Practice

echo ===== Git Configuration =====
set /p username=Enter Git username:
set /p email=Enter Git email:

git config --global user.name "%username%"
git config --global user.email "%email%"

echo.
echo ===== Creating Project =====
mkdir GitPractice 2>nul
cd GitPractice
mkdir EventRegistration 2>nul
cd EventRegistration

(
echo ^<html^>
echo ^<head^>^<title^>Event Registration^</title^>^</head^>
echo ^<body^>
echo ^<h2^>Event Registration^</h2^>
echo ^<form^>
echo Name: ^<input type="text" required^> ^<br^>^<br^>
echo Email: ^<input type="email" required^> ^<br^>^<br^>
echo ^<button^>Register^</button^>
echo ^</form^>
echo ^</body^>
echo ^</html^>
) > index.html

start "" index.html

echo.
echo ===== Git Source Control =====
git init
git status
git add index.html
git commit -m "Add event registration form"
git log

echo.
echo ===== GitHub Upload =====
set /p repo=Enter GitHub repository HTTPS URL:

git branch -M main
git remote add origin "%repo%"
git push -u origin main

echo.
echo ===== Completed =====
pause
