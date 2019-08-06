set APP_XML_TEMP=obj\application-template.xml
set APP_XML=application.xml
set ANA_KEY_AND=8ecad253293db70a84469b3d79243f12
set ANA_SEC_AND=6c3abba9c19b989f5e45749396bcb1b78b51fbf2
set ANA_KEY_IOS=000000
set ANA_SEC_IOS=111111
if "%PLATFORM%"=="android" (set ANA_KEY=%ANA_KEY_AND%) else (set ANA_KEY=%ANA_KEY_IOS%) 
if "%PLATFORM%"=="android" (set ANA_SEC=%ANA_SEC_AND%) else (set ANA_SEC=%ANA_SEC_IOS%) 

set DESC_TEMP=__DESCRIPTION__
set DESC_FINE={ "platform": "%PLATFORM%", "market": "%MARKET%", "server": "%SERVER%", "analyticskey": "%ANA_KEY%", "analyticssec": "%ANA_SEC%" }

set PERMISSION_TEMP=com.domain.market.BILLING
set PERMISSION_FINE=com.domain.market.BILLING
if %MARKET%==cafebazaar	set PERMISSION_FINE=com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR
if %MARKET%==google		set PERMISSION_FINE=com.android.vending.BILLING
if %MARKET%==myket		set PERMISSION_FINE=ir.mservices.market.BILLING
if %MARKET%==ario		set PERMISSION_FINE=com.arioclub.android.sdk.IAB
if %MARKET%==cando		set PERMISSION_FINE=com.ada.market.BILLING


::echo %MARKET%...%PLATFORM%...%PERMISSION_FINE%

(for /f "delims=" %%i in (%APP_XML_TEMP%) do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    set "line=!line:%DESC_TEMP%=%DESC_FINE%!"
    set "line=!line:%PERMISSION_TEMP%=%PERMISSION_FINE%!"
    echo(!line!
    endlocal
))>"%APP_XML%"