@echo off
setlocal
cd /d "%~dp0"
where texlua >nul 2>&1
if errorlevel 1 (
 echo Para testes automatizados instale Lua ou TeX Live / texlua.
 pause
 exit /b 1
)
set "failed=0"
for %%F in (run v4_regression v5_regression v6_regression v7_regression v8_regression v9_regression v9_storage v10_swim v10_ui_smoke v11_timeline v11_research v11_ui_smoke v12_offline v12_save_safety v13_integrity v14_render v15_controls view_smoke v5_ui_smoke v6_ui_smoke v7_ui_smoke v8_ui_smoke v9_ui_smoke lifecycle_smoke jar_resources_smoke v8_performance) do (
 echo Verificando %%F...
 texlua "tests/%%F.lua" || set "failed=1"
)
if "%failed%"=="1" (
 echo Verificacoes com falha.
 exit /b 1
)
echo Verificacoes finalizadas.
