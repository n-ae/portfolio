@echo off 

SET company=Arintel
SET app_name=Service.Scheduler
SET service_name=%company%.%app_name%
ECHO %service_name%
SET binary_name=live\%app_name%.exe
SET pwd=%~dp0

sc.exe stop %service_name%
sc.exe delete %service_name%
sc.exe create %service_name% binPath=%pwd%%binary_name%
sc.exe config %service_name% start=delayed-auto
sc.exe start %service_name%
sc.exe description %service_name% "https://github.com/arinteltech/%app_name%"
