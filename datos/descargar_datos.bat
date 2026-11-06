@echo off
REM ===========================================================================
REM  TP Bases de Datos Aplicada - Grupo 01 - Entrega 6
REM  Descarga los archivos de datos tal como los publican sus fuentes y los
REM  copia a C:\Mundial2026\datos\ (carpeta que lee SQL Server).
REM  Requiere Windows 10 o superior (incluye curl y tar).
REM ===========================================================================
setlocal
cd /d "%~dp0"
set LOG=%~dp0descarga_log.txt
echo Descarga iniciada %date% %time% > "%LOG%"

call :bajar "https://raw.githubusercontent.com/datasets/country-codes/main/data/country-codes.csv" country-codes.csv
call :bajar "https://download.geonames.org/export/dump/timeZones.txt" timeZones.txt
call :bajar "https://download.geonames.org/export/dump/cities15000.zip" cities15000.zip
call :bajar "https://raw.githubusercontent.com/openfootball/worldcup.json/master/2026/worldcup.stadiums.json" worldcup.stadiums.json
call :bajar "https://raw.githubusercontent.com/openfootball/worldcup.json/master/2026/worldcup.teams.json" worldcup.teams.json
call :bajar "https://raw.githubusercontent.com/openfootball/worldcup.json/master/2026/worldcup.json" worldcup.json
call :bajar "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml" eurofxref-hist-90d.xml

REM El archivo de ciudades se publica comprimido: se extrae sin modificarlo.
tar -xf cities15000.zip >> "%LOG%" 2>&1
if exist cities15000.txt (echo OK extraido cities15000.txt >> "%LOG%") else (echo ERROR al extraer cities15000.zip >> "%LOG%")

REM Copia a la carpeta que lee la cuenta del servicio de SQL Server.
if not exist C:\Mundial2026\datos\pruebas mkdir C:\Mundial2026\datos\pruebas
xcopy /y /q "%~dp0*.csv" C:\Mundial2026\datos\ >> "%LOG%" 2>&1
xcopy /y /q "%~dp0*.txt" C:\Mundial2026\datos\ >> "%LOG%" 2>&1
xcopy /y /q "%~dp0*.json" C:\Mundial2026\datos\ >> "%LOG%" 2>&1
xcopy /y /q "%~dp0*.xml" C:\Mundial2026\datos\ >> "%LOG%" 2>&1
xcopy /y /q "%~dp0pruebas\*" C:\Mundial2026\datos\pruebas\ >> "%LOG%" 2>&1

echo Descarga finalizada %date% %time% >> "%LOG%"
type "%LOG%"
echo.
echo Listo. Los archivos quedaron en C:\Mundial2026\datos\
pause
exit /b

:bajar
curl -L -s -S --fail -A "Mundial2026-TP-BDA-UNLaM/1.0" -o "%~2" "%~1"
if errorlevel 1 (echo ERROR %~2 desde %~1 >> "%LOG%") else (echo OK %~2 >> "%LOG%")
exit /b
