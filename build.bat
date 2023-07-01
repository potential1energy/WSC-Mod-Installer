@echo off
set /p "id=Enter Name: "
mkdir build
cd build
mkdir temp
mkdir build
copy "C:\Program Files\LOVE\love.exe"
robocopy "C:\Program Files\LOVE" "%cd%" *.dll
cd ..
robocopy "%cd%" "%cd%\build\temp" /e /xd build /xf build.bat /xd .vscode /xd .git
7z a -tzip "%cd%\build\build.zip" "%cd%\build\temp\*"
cd "%cd%\build\"
ren build.zip build.love
copy /b love.exe+build.love "%cd%\build\%id%.exe"
robocopy "%cd%" "%cd%\build" *.dll
del /q *.*
robocopy "%cd%\build" "%cd%"
rd /q /s "%cd%\build"
rd /q /s "%cd%\temp"