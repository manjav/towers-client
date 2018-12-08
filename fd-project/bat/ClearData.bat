@echo off
cd %~dp0 & cd ..


:: Your application ID (must match <id> of Application descriptor) and remove spaces
set APP_XML=application.xml
for /f "tokens=3 delims=<>" %%a in ('findstr /R /C:"^[ 	]*<id>" %APP_XML%') do set APP_ID=%%a
set APP_ID=%APP_ID: =%

set SFS_XML=bin\sfs-config.xml
for /f "tokens=3 delims=<>" %%b in ('findstr /R /C:"^[ 	]*<ip>" %SFS_XML%') do set APP_IP=%%b
set APP_IP=%APP_IP: =%



echo Delete %APP_IP%-user-data.sol ?
pause
cd %AppData%\%APP_ID%\Local Store\#SharedObjects\release.swf
del /F /Q %APP_IP%-user-data.sol
