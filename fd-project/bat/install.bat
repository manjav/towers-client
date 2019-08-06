@echo off
cd %~dp0 & cd ..
set APP_XML=application.xml
:: Your application ID (must match <id> of Application descriptor) and remove spaces
for /f "tokens=3 delims=<>" %%a in ('findstr /R /C:"^[     ]*<id>" %APP_XML%') do set APP_ID=%%a
set APP_ID=%APP_ID: =%

"C:\_projects\4.6.0+26.0.0\lib\android\bin\adb" devices
"C:\_projects\4.6.0+31.0.0\lib\android\bin\adb" devices
set /p APK_FILE="Drag APK: "
"C:\_projects\4.6.0+26.0.0\lib\android\bin\adb" -d install -r "%APK_FILE%"
"C:\_projects\4.6.0+26.0.0\lib\android\bin\adb" shell am start -n air.%APP_ID%/.AppEntry
"C:\_projects\4.6.0+31.0.0\lib\android\bin\adb" -d install -r "%APK_FILE%"
"C:\_projects\4.6.0+31.0.0\lib\android\bin\adb" shell am start -n air.%APP_ID%/.AppEntry
pause
