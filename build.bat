@echo off
rem ==========================================================
rem  build.bat - Java(Servlet/DAO) compile for Mine Cake
rem  Result: src\main\webapp\WEB-INF\classes  (Tomcat reads this)
rem  Run again every time you change a .java file.
rem ==========================================================
setlocal
cd /d "%~dp0"

rem 1) Find Tomcat 10.1 (or set TOMCAT_HOME yourself)
if "%TOMCAT_HOME%"=="" for /d %%D in ("C:\tomcat\apache-tomcat-10.1*") do set "TOMCAT_HOME=%%D"
if not exist "%TOMCAT_HOME%\lib\servlet-api.jar" (
  echo [ERROR] Tomcat 10.1 not found. Unzip it to C:\tomcat\apache-tomcat-10.1.xx
  echo         or run:  set TOMCAT_HOME=C:\your\tomcat\folder
  exit /b 1
)
echo Tomcat : %TOMCAT_HOME%

rem 2) Clean output folder
set "OUT=src\main\webapp\WEB-INF\classes"
if exist "%OUT%" rmdir /s /q "%OUT%"
mkdir "%OUT%"

rem 3) Compile (add a line here if you make a new package folder)
javac -encoding UTF-8 --release 17 -cp "%TOMCAT_HOME%\lib\servlet-api.jar" -d "%OUT%" ^
  src\main\java\com\minecake\ai\*.java ^
  src\main\java\com\minecake\controller\*.java ^
  src\main\java\com\minecake\controller\admin\*.java ^
  src\main\java\com\minecake\dao\*.java ^
  src\main\java\com\minecake\dto\*.java ^
  src\main\java\com\minecake\util\*.java
if errorlevel 1 (
  echo [ERROR] Compile failed. Check the red messages above.
  exit /b 1
)

echo [OK] Build finished. Restart Tomcat in VS Code (SERVERS - Restart).
endlocal
