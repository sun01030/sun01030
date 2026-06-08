@echo off
REM ========================================
REM PostgreSQL 到 MSSQL 資料遷移指令 (修正版)
REM ========================================

setlocal enabledelayedexpansion

REM ========== 設定變數 ==========
set PGSQL_HOST=pxmart.aims.solumesl.com
set PGSQL_PORT=9010
set PGSQL_DB=AIMS_PORTAL_DB
set PGSQL_USER=unitech
set PGSQL_PASSWORD=Unitech
set PGSQL_TABLE=end_device

set CSV_FILE=C:\temp\export_data.csv
set LOG_FILE=C:\temp\migration_log.txt
set SQL_FILE=C:\temp\export_query.sql
set TIMESTAMP=%date:~10,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%

REM ========== 建立臨時資料夾 ==========
if not exist C:\temp mkdir C:\temp

echo [%TIMESTAMP%] 開始資料遷移... >> %LOG_FILE%

REM ========== 步驟 1：建立 SQL 查詢檔案 ==========
echo.
echo [步驟 1] 建立 SQL 查詢檔案...
echo [%TIMESTAMP%] 建立 SQL 查詢檔案... >> %LOG_FILE%

(
    echo \copy %PGSQL_TABLE% TO STDOUT WITH CSV HEADER DELIMITER ',';
) > %SQL_FILE%

if exist %SQL_FILE% (
    echo ✓ SQL 檔案建立成功！
    echo [%TIMESTAMP%] SQL 檔案建立成功！ >> %LOG_FILE%
) else (
    echo ✗ SQL 檔案建立失敗！
    echo [%TIMESTAMP%] SQL 檔案建立失敗！ >> %LOG_FILE%
    pause
    exit /b 1
)

REM ========== 步驟 2：從 PostgreSQL 匯出 CSV ==========
echo.
echo [步驟 2] 從 PostgreSQL 匯出 CSV 檔案...
echo [%TIMESTAMP%] 從 PostgreSQL 匯出 CSV 檔案... >> %LOG_FILE%

set PGPASSWORD=%PGSQL_PASSWORD%

REM 使用 -f 參數執行 SQL 檔案
psql -h %PGSQL_HOST% -p %PGSQL_PORT% -U %PGSQL_USER% -d %PGSQL_DB% -f %SQL_FILE% > %CSV_FILE%

if %errorlevel% equ 0 (
    echo.
    echo ✓ CSV 匯出成功！
    echo ✓ 檔案位置：%CSV_FILE%
    echo [%TIMESTAMP%] CSV 匯出成功！ >> %LOG_FILE%
) else (
    echo.
    echo ✗ CSV 匯出失敗！錯誤代碼：%errorlevel%
    echo [%TIMESTAMP%] CSV 匯出失敗！錯誤代碼：%errorlevel% >> %LOG_FILE%
    pause
    exit /b 1
)

REM ========== 清理臨時檔案 ==========
echo.
echo [步驟 3] 清理臨時檔案...
if exist %SQL_FILE% del /f /q %SQL_FILE%

echo.
echo ========================================
echo 資料遷移全部完成！
echo 詳細日誌：%LOG_FILE%
echo ========================================
echo [%TIMESTAMP%] 資料遷移全部完成！ >> %LOG_FILE%

pause
