@echo off
cd %~dp0 & cd ..

:: Your application ID (must match <id> of Application descriptor) and remove spaces
set APP_XML=application.xml
for /f "tokens=3 delims=<>" %%a in ('findstr /R /C:"^[ 	]*<id>" %APP_XML%') do set APP_ID=%%a
set APP_ID=%APP_ID: =%


:: find value <description> of Application descriptor and remove spaces
for /f "tokens=3 delims=<>" %%a in ('findstr /R /C:"^[ 	]*<description>" %APP_XML%') do set string=%%a

::parse json config
rem Remove quotes
set string=%string:"=%
rem Remove braces
set "string=%string:~2,-2%"
rem Change colon+space by equal-sign
set "string=%string:: ==%"
rem Separate parts at comma into individual assignments
set "%string:, =" & set "%"


:: delete application data
echo Delete %server%-user-data.sol ?
pause
cd %AppData%\%APP_ID%\Local Store\
del /F /Q #SharedObjects\release.swf\%server%-user-data.sol
del /F /Q config.xml