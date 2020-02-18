@echo off
:: Set working dir
cd %~dp0 & cd ..

:: Get date with this template =>mouth day hours minutes seconds
set DATE=%date:~-10,2%%date:~-7,2%%time:~-11,2%%time:~-8,2%
:: Replace space with 0
for %%a in (%DATE: =0%) do set DATE=%%a

:: Application descriptor
set VER_ID=0.4.300
set VER_LABEL=%VER_ID%.%DATE%
set APP_ID=com.grantech.towers
set APP_NAME=KOOT
set CODE_NAME=koot
echo %VER_LABEL%
:: Game Analytics
set GA_KEY_AND=8ecad253293db70a84469b3d79243f12
set GA_SEC_AND=6c3abba9c19b989f5e45749396bcb1b78b51fbf2
set GA_KEY_IOS=GA_KEY_IOS
set GA_SEC_IOS=GA_SEC_IOS

if [%SERVER%]==[] set SERVER=iran
if [%MARKET%]==[] set MARKET=cafebazaar
if [%PLATFORM%]==[] set PLATFORM=android
if NOT %SERVER%==iran set APP_ID=%APP_ID%.%SERVER%

:: Debugging using a custom IP
set DEBUG_IP=