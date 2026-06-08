@echo off
REM ========================================
REM PostgreSQL SQL Query Export to CSV File
REM ========================================

setlocal enabledelayedexpansion

REM ========== Set Variables ==========
set PGSQL_HOST=pxmart.aims.solumesl.com
set PGSQL_PORT=9010
set PGSQL_DB=AIMS_PORTAL_DB
set PGSQL_USER=unitech
set PGSQL_PASSWORD=Unitech

set CSV_FILE=C:\temp\export_data.csv
set LOG_FILE=C:\temp\migration_log.txt
set TIMESTAMP=%date:~10,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%

REM ========== Create Temp Folder ==========
if not exist C:\temp mkdir C:\temp

echo.
echo ========================================
echo PostgreSQL CSV Export Tool
echo ========================================
echo [%TIMESTAMP%] Start exporting... >> %LOG_FILE%

REM ========== Step 1: Prepare SQL Query ==========
echo.
echo [Step 1] Preparing SQL query...
echo [%TIMESTAMP%] Preparing SQL query... >> %LOG_FILE%

REM ========== Step 2: Export CSV from PostgreSQL ==========
echo.
echo [Step 2] Exporting CSV file from PostgreSQL...
echo [%TIMESTAMP%] Exporting CSV file from PostgreSQL... >> %LOG_FILE%

set PGPASSWORD=%PGSQL_PASSWORD%

REM Execute SQL command directly using -c parameter (single session)
echo Connecting to database...
psql -h %PGSQL_HOST% -p %PGSQL_PORT% -U %PGSQL_USER% -d %PGSQL_DB% -c "CREATE TEMPORARY TABLE temp_export AS SELECT edai.* , eda.article_id, edt.name as templateName FROM end_device e JOIN end_device_add_info edai ON edai.label_code = e.label_code JOIN end_device_articles eda ON eda.label_code = e.label_code JOIN end_device_templates edt ON edt.label_code = e.label_code GROUP BY edai.label_code, eda.article_id, edt.name ORDER BY edai.label_code LIMIT 1; \copy temp_export TO STDOUT WITH CSV HEADER DELIMITER ',';" > %CSV_FILE% 2>>%LOG_FILE%

if %errorlevel% equ 0 (
    echo.
    echo ✓ CSV export succeeded!
    echo ✓ File location: %CSV_FILE%
    echo [%TIMESTAMP%] CSV export succeeded! >> %LOG_FILE%
    
    REM Display number of exported rows
    for /f %%A in ('find /c /v "" %CSV_FILE%') do (
        echo ✓ Total rows exported: %%A
        echo [%TIMESTAMP%] Total rows exported: %%A >> %LOG_FILE%
    )
) else (
    echo.
    echo ✗ CSV export failed!
    echo ✗ Error code: %errorlevel%
    echo [%TIMESTAMP%] CSV export failed! Error code: %errorlevel% >> %LOG_FILE%
    echo.
    echo Please check the following:
    echo 1. PostgreSQL server is running
    echo 2. Username and password are correct
    echo 3. Database connection is working
    echo 4. Check log file for detailed error message
    echo.
    echo Log file: %LOG_FILE%
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo.
echo ========================================
echo ✓ CSV export completed successfully!
echo File location: %CSV_FILE%
echo Log file: %LOG_FILE%
echo ========================================
echo [%TIMESTAMP%] CSV export completed successfully! >> %LOG_FILE%
echo.
echo Press any key to exit...
pause >nul
