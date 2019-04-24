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

:menu
echo.
echo Change server after deletion?
echo.
echo  [0] no change
echo  [1] iran
echo  [2] local

:choice
set /P S=[Choice]: 
echo.

set SERVER=iran
if "%S%"=="0" goto clear
if "%S%"=="1" set SERVER=iran
if "%S%"=="2" set SERVER=local
set MARKET=cafebazaar
call bat\SetupDescriptor.bat

:clear

cd %AppData%\%APP_ID%\Local Store\
del /F /Q #SharedObjects\release.swf\%server%-user-data.sol
del /F /Q config.xml