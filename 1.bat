
@echo off
mkdir EventRegistration 2>nul
cd EventRegistration

(
echo ^<!DOCTYPE html^>
echo ^<html^>
echo ^<head^>^<title^>Event Registration^</title^>^</head^>
echo ^<body^>
echo ^<h2^>Event Registration Form^</h2^>
echo ^<form^>
echo Name: ^<input type="text" required^> ^<br^>^<br^>
echo Email: ^<input type="email" required^> ^<br^>^<br^>
echo Phone: ^<input type="tel" required^> ^<br^>^<br^>
echo Event: ^<select^>
echo ^<option^>Workshop^</option^>
echo ^<option^>Hackathon^</option^>
echo ^<option^>Seminar^</option^>
echo ^</select^> ^<br^>^<br^>
echo ^<button type="submit"^>Register^</button^>
echo ^</form^>
echo ^</body^>
echo ^</html^>
) > index.html

start "" index.html
echo Registration page created successfully!
pause
