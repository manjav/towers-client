@echo on

@RD /S /Q ext

mkdir ext

pushd ane
for /r %%i in (*.ane) do (
    move %%i %%i.zip
    unzip -o %%i.zip -d %%i
    move %%i ..\ext\
    move %%i.zip %%i
)
popd