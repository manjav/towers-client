set APP_XML_TEMP=application-template.xml
set APP_XML=application.xml
set DESC_TEMP=__DESCRIPTION__
set DESC_FINE={"platform":"%PLATFORM%", "market":"%MARKET%"}

set PERMISSION_TEMP=uses-permission-market
set PERMISSION_FINE=uses-permission-market
if %MARKET%==cafebazaar	set PERMISSION_FINE=uses-permission android:name="com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR"
if %MARKET%==google		set PERMISSION_FINE=uses-permission android:name="com.android.vending.BILLING"
if %MARKET%==myket		set PERMISSION_FINE=uses-permission android:name="ir.mservices.market.BILLING"
if %MARKET%==ario		set PERMISSION_FINE=uses-permission android:name="com.arioclub.android.sdk.IAB"

::echo %MARKET%...%PLATFORM%...%PERMISSION_FINE%

(for /f "delims=" %%i in (%APP_XML_TEMP%) do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    set "line=!line:%DESC_TEMP%=%DESC_FINE%!"
    set "line=!line:%PERMISSION_TEMP%=%PERMISSION_FINE%!"
    echo(!line!
    endlocal
))>"%APP_XML%"