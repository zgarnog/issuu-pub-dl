@echo off

echo.
echo Issuu Publication Downloader v1.0
echo by eqagunn
echo.
echo   # == mod1 == ( by zgarnog <zgarnog@yandex.com> )
echo   #
echo   # 2015-04-20
echo   #  - now uses leading zeros on numbers less than 100
echo   #
echo.

if [%1]==[] (echo. & set /p id=Document ID: ) else (set id=%1)

if [%2]==[] (echo. & set /p pages=Number of Pages: ) else (set pages=%2)

if [%3]==[] (set dest=\%id%) else (set dest=\%~3)

set /a page=1


mkdir ".\downloads%dest%\"

echo.
echo WARNING - will overwrite files under ".\downloads%dest%\"
echo Press any key to continue
pause >nul

echo.
echo Downloading. Please wait...


setlocal ENABLEDELAYEDEXPANSION

:loop

if %page% lss 10 (
  set dest_file_page=00%page%
) else (
  if %page% lss 100 (
    set dest_file_page=0%page%
  ) else (
    set dest_file_page=%page%
  )
)

set /a mod_page=%page% %% 10

if [%mod_page%]==[0] (
  echo on page %dest_file_page% / %pages%
)

wget -nv -q --output-document=".\downloads%dest%\page_%dest_file_page%.jpg" "http://image.issuu.com/%id%/jpg/page_%page%.jpg"

set /a page=%page%+1

if %page% leq %pages% goto loop

echo.
echo Done; downloaded %page% pages.

echo.
echo Press any key to exit...
pause >nul


