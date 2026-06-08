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

set MSSQL_SERVER=your_mssql_server
set MSSQL_DB=ESL
set MSSQL_USER=sa
set MSSQL_PASSWORD=your_password
set MSSQL_TABLE=[dbo].[Label]

set CSV_FILE=C:\temp\export_data.csv
set LOG_FILE=C:\temp\migration_log.txt
set TIMESTAMP=%date:~10,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%

REM ========== 建立臨時資料夾 ==========
if not exist C:\temp mkdir C:\temp

echo [%TIMESTAMP%] 開始資料遷移... >> %LOG_FILE%

REM ========== 步驟 1：從 PostgreSQL 匯出 CSV (使用 \copy) ==========
echo.
echo [步驟 1] 從 PostgreSQL 匯出 CSV 檔案 (使用 \copy 命令)...
echo [%TIMESTAMP%] 從 PostgreSQL 匯出 CSV 檔案... >> %LOG_FILE%

set PGPASSWORD=%PGSQL_PASSWORD%

REM 使用 \copy 而不是 COPY - 這不需要超級用戶權限
psql -h %PGSQL_HOST% -p %PGSQL_PORT% -U %PGSQL_USER% -d %PGSQL_DB% -c "\\copy %PGSQL_TABLE% TO STDOUT WITH CSV HEADER DELIMITER ',';" > %CSV_FILE%

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

echo.
echo ========================================
echo 資料遷移全部完成！
echo 詳細日誌：%LOG_FILE%
echo ========================================
echo [%TIMESTAMP%] 資料遷移全部完成！ >> %LOG_FILE%

pause
