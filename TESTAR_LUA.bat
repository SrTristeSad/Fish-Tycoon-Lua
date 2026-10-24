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
for %%F in (run v4_regression v5_regression v6_regression v7_regression v8_regression v9_regression v9_storage v10_swim v10_ui_smoke v11_timeline v11_research v11_ui_smoke v12_offline v12_save_safety v13_integrity v14_render v15_controls v15_jar_genetics v17_biology v18_contagion v19_retro v20_visual_controls v21_shop_research v22_keypad v23_bitmap_font v24_viewport v25_controls v26_sale_art v27_menu v28_actions v29_navigation_icons v30_selection v31_motion v32_fish_sizes v33_isolation_layout v34_detail_overlay v35_selection_panel v36_selection_scissor v37_trophy view_smoke v5_ui_smoke v6_ui_smoke v7_ui_smoke v8_ui_smoke v9_ui_smoke lifecycle_smoke jar_resources_smoke v8_performance) do (
 echo Verificando %%F...
 texlua "tests/%%F.lua" || set "failed=1"
)
if "%failed%"=="1" (
 echo Verificacoes com falha.
 exit /b 1
)
echo Verificacoes finalizadas.
