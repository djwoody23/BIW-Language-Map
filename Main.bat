@ECHO OFF
CALL "%~d0\Libs\Setup.bat" > NUL
::SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

SET CURRENT_FILE=%0
SET CURRENT_DRIVE=%~d0
CHCP 437 > NUL

TITLE PhoneGap Helper


:START
CALL :INIT
CALL :MAINMENU_INIT
GOTO :MAINMENU


:MAINMENU
CALL :MAINMENU_TEXT
CALL :PARSE :MAINMENU_COMMAND
GOTO :MAINMENU


:MAINMENU_INIT
CALL :GENERATESEPARATOR _ " " 114
CALL :GENERATESEPARATOR - "�" 114
CALL :GENERATESEPARATOR # "�" 114
CALL :GENERATESEPARATOR @ "�" 114

CALL :MENUITEMLABEL PROJECT	  		"PROJECT:       !PROJECT_NAME!"
CALL :MENUITEMLABEL APK_MODE	  	"MODE:          !APK_MODE!"
CALL :MENUITEMLABEL DIRECTORY		"DIRECTORY:     "!__CD__!""
CALL :MENUITEMLABEL APK	  			"APK:           !APK!"
CALL :MENUITEMLABEL APK_ZIP	  		"ZIP:           !APK_ZIP!"
CALL :MENUITEMLABEL APK_PACKAGE	  	"PACKAGE:       !APK_PACKAGE!"
CALL :MENUITEMLABEL APK_ACTIVITY	"ACTIVITY:      !APK_ACTIVITY!"
CALL :MENUITEMLABEL APK_SIZE		"APK SIZE:      !APK_SIZE!"
CALL :MENUITEMLABEL APK_ZIP_SIZE	"ZIP SIZE:      !APK_ZIP_SIZE!"
CALL :MENUITEMLABEL PGB_ID			"PHONEGAP ID:   !PGB_ID!"

CALL :MENUITEM EMULATOR			E "Start Emulator"
CALL :MENUITEM LOGAPK			L "Start Log APK"
CALL :MENUITEM LOGERROR			X "Start Log Error                (Useful if APK is crashing)"
CALL :MENUITEM SETDIR			S "Set Current Dir"
CALL :MENUITEM SETAPK			A "Set APK"
CALL :MENUITEM SETMODE			M "Set Mode                       (Debug/Release)"
CALL :MENUITEM BUILDRES			B "Build Resources                (Builds the splash and icons)"
CALL :MENUITEM UPLOAD			U "PHONEGAP - Upload              (Zips and Uploads)"
CALL :MENUITEM DOWNLOAD			D "PHONEGAP - Download"
CALL :MENUITEM DOWNLOAD_WAIT	W "PHONEGAP - Wait For Build"
CALL :MENUITEM INITPLATFORM		7 "LOCAL    - Initialize Platform"
CALL :MENUITEM BUILDAPK			8 "LOCAL    - Build APK"
CALL :MENUITEM SERVEAPK			1 "LIVE     - Serve APK           (For the Phonegap App)"
CALL :MENUITEM INSTAPK			9 "Install APK"
CALL :MENUITEM RUNAPK			0 "Run APK"
CALL :MENUITEM PROMPT			P "Command Prompt"
CALL :MENUITEM GITGUI			G "Git GUI"
CALL :MENUITEM HELP				H "Help"
CALL :MENUITEM RESTART			R "Restart"
CALL :MENUITEM QUIT				Q "Quit"
CALL :MENUITEM COMMAND			C "Run Command"

SET MAINMENU_LIST="# # _ PROJECT APK_PACKAGE APK_ACTIVITY PGB_ID APK_MODE _ DIRECTORY APK APK_ZIP _ APK_SIZE APK_ZIP_SIZE _ - _ SETDIR SETAPK SETMODE _ - _ EMULATOR LOGAPK LOGERROR _ - _ BUILDRES _ UPLOAD DOWNLOAD DOWNLOAD_WAIT _ SERVEAPK _ INITPLATFORM BUILDAPK _ INSTAPK RUNAPK _ - _ COMMAND PROMPT _ GITGUI _ - _ HELP RESTART QUIT _ @ _"
GOTO :EOF

:MAINMENU_TEXT
CALL :MENUITEMPRINT %MAINMENU_LIST%
GOTO :EOF

:MAINMENU_COMMAND
CALL :MENUITEMCHECK %MAINMENU_LIST% %1
GOTO :EOF




:PARSE
CALL :MENUITEMPRINT "_ _ @"
CALL CursorPos.exe 1,-3
SET QUERY=
SET /P QUERY=Input: 
CALL :MENUITEMPRINT "_ @ _"

IF "%QUERY%"=="" GOTO :EOF
IF NOT "%QUERY:~0,1%"=="-" GOTO :PARSEONE
SET "QUERY=%QUERY:~1%"

:PARSELOOP
IF "%QUERY%"=="" GOTO :PARSEEND
CALL %1 %QUERY:~0,1%
SET "QUERY=%QUERY:~1%"
IF NOT "%QUERY%"=="" CALL :MENUITEMPRINT "_ - _"
GOTO :PARSELOOP

:PARSEONE
CALL %1 %QUERY%

:PARSEEND

CALL :MENUITEMPRINT "_"
SET QUERY=
GOTO :EOF





:MENUITEMLABEL
SET "_%1_TEXT= %~2"
GOTO :EOF

:MENUITEM
::%1 = ID; %2 = Command; %3 = Text
SET "_%1_COMMAND=%2"
SET "_%1_TEXT= (%2) %~3"
GOTO :EOF


:MENUITEMPRINT
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
FOR %%I IN (%~1) DO (
	FOR /F "eol=;delims=" %%A IN ("!_%%I_TEXT!") DO (
		ECHO.%%~A
	)
)
ENDLOCAL
GOTO :EOF

:MENUITEMCHECK
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
FOR %%I IN (%~1) DO (
	IF /I "!_%%I_COMMAND!"=="%2" (
		ENDLOCAL
		CALL :MENUITEMPRINT %%I & ECHO. & GOTO :%%I
	)
)
ECHO UNKNOWN COMMAND "%2"
ENDLOCAL
GOTO :EOF


:MENUSEPARATOR
CALL :MENUITEMPRINT "_ - _"
GOTO :EOF

:GENERATESEPARATOR
SET "VAL=%~2"
FOR /L %%A IN (1,1,%3) DO CALL SET "VAL=%%VAL%%%~2"
SET "_%~1_TEXT=%VAL%"
SET VAL=
GOTO :EOF






:UNSET
FOR %%I IN (%~1) DO SET "%%I="
GOTO :EOF



:INIT

ECHO.
ECHO INIT
ECHO.

CALL :UNSET "PROJECT_NAME APK APK_ZIP APK_PACKAGE APK_ACTIVITY APK_SIZE APK_ZIP_SIZE APK_MODE PGB_ID"

SET "APK_MODE=debug"
FOR /F "delims=" %%A IN ('sed -n -e "/^\s*<name>/s/^\s*<name>\s*\([^<]*\)\s*<\/name>\s*$/\1/p" config.xml') DO (
	SET "PROJECT_NAME=%%A"
	CALL :UPDATE_NAME
)

CHOICE /C NY /N /T 5 /D N /M "Release Mode (Y/N): "
SET _B_DEB=%ERRORLEVEL%

CHOICE /C YN /N /T 5 /D N /M "Build Resources (Y/N): "
SET _B_RES=%ERRORLEVEL%

ECHO.
CALL :COPYOVERRIDES
ECHO.
CALL :SETMODE_VAL %_B_DEB%
ECHO.
IF %_B_RES%==1 ( CALL :BUILDRES )

CALL :UNSET "_B_RES _B_DEB"
CLS
GOTO :EOF



:SETMODE_VAL
IF %1==1 ( SET "APK_MODE=debug" ) ELSE ( SET "APK_MODE=release" )
CALL :UPDATE_NAME
GOTO :EOF

:SETMODE
ECHO (D) Debug
ECHO (R) Release
CHOICE /C DR /N /M "Input: "
CALL SETMODE_VAL %ERRORLEVEL%
GOTO :EOF



:UPDATE_NAME
SET "APK=%__CD__%%PROJECT_NAME: =%"
SET APK_ZIP="%APK%.zip"
SET APK="%APK%-%APK_MODE%.apk"

CALL :UPDATE_APK
CALL :UPDATE_ID
GOTO :EOF


:UPDATE_APK
CALL :COMMA %APK% APK_SIZE
CALL :COMMA %APK_ZIP% APK_ZIP_SIZE

CALL :UNSET "APK_PACKAGE APK_ACTIVITY"

IF NOT EXIST %APK% GOTO :EOF

SET "APK_SED=aapt dump badging %APK% ^| sed -n -e"
SET APK_PACKAGE_PATTERN="/^package: /s/.*name='\([^']*\)'.*$/\1/p"
SET APK_ACTIVITY_PATTERN="/^launchable-activity:/s/.*name='\([^']*\)'.*$/\1/p"

FOR /F %%A IN ('%APK_SED% %APK_PACKAGE_PATTERN%')  DO SET "APK_PACKAGE=%%A"
FOR /F %%A IN ('%APK_SED% %APK_ACTIVITY_PATTERN%') DO SET "APK_ACTIVITY=%%A"

CALL :UNSET "APK_SED APK_PACKAGE_PATTERN APK_ACTIVITY_PATTERN"

GOTO :EOF


:UPDATE_ID
IF NOT "%PGB_ID%"=="" GOTO :EOF
FOR /F %%A IN ('CALL pgbuild list ^<^&1 2^> NUL ^| sed -n -e "/^id:.*%PROJECT_NAME%/s/^id:\s*\([0-9]*\).*$/\1/p"') DO (SET "PGB_ID=%%A")
IF NOT "%PGB_ID%"=="" GOTO :EOF
CALL pgbuild list
GOTO :EOF


:COMMA
SET "VALUE=%~z1"
IF "%VALUE%"=="" (
	SET "%2="
	GOTO :COMMAEND
)
SET "%2= Bytes"
:COMMALOOP
CALL SET "%2=%VALUE:~-3%%%%2%%"
SET "VALUE=%VALUE:~0,-3%"
IF "%VALUE%"=="" GOTO :COMMAEND
CALL SET "%2=,%%%2%%"
GOTO :COMMALOOP
:COMMAEND
CALL :UNSET "VALUE"
GOTO :EOF





:EMULATOR
ECHO RUN EMULATOR
START "" "%ANDROID_HOME%\AVD Manager.exe"
::SET /P AVD=Enter device name: 
::START "Emulator" %EMULATOR% -avd %AVD%
GOTO :EOF

:LOGAPK
ECHO START   LOG APK
START "Log CordovaLog" adb logcat CordovaLog:D *:S
GOTO :EOF

:LOGERROR
ECHO START   LOG ERROR
START "Log Error" adb logcat *:E
GOTO :EOF

:SETDIR
ECHO SET DIR
SETLOCAL
SET /P DIR=Enter Project Directory: 
CD %DIR%
ENDLOCAL
CALL :UPDATE_APK
GOTO :EOF

:SETAPK
ECHO SET APK
SET /P APK=Drag apk file here: 
CALL :UPDATE_APK
GOTO :EOF


:COMPRESS
IF EXIST %APK_ZIP% ( DEL /S /Q %APK_ZIP% & ECHO. )
ECHO COMPRESSING
ECHO.
ECHO "-x!"  means exclude
ECHO "-xr!" means exclude recursively
ECHO.
SETLOCAL
SET "INCLUDE_FILES=config.xml www\config.xml res\ www\"
SET "EXCLUDE_FILES=-xr^!*.db -x^!res\screen.png -x^!res\ios\*"
::SET "EXCLUDE_FILES=%EXCLUDE_FILES% -x^!www\audio\ -x^!www\images\dictionary\"
ECHO INCLUDING: %INCLUDE_FILES% %EXCLUDE_FILES%
CALL 7z a -tzip %APK_ZIP% -mx9 %INCLUDE_FILES% %EXCLUDE_FILES% > NUL
ENDLOCAL
CALL :UPDATE_APK
GOTO :EOF


:UPLOAD_PG
ECHO.
ECHO UPLOADING
ECHO.
CALL pgbuild update %PGB_ID% %APK_ZIP%
ECHO.
ECHO COMPLETED
GOTO :EOF


:UPLOAD
CALL :UPDATE_ID
CALL :COMPRESS
CALL :UPLOAD_PG
ECHO COMPLETED
GOTO :EOF


:DOWNLOAD_WAIT
FOR /F "delims=" %%A IN ('CALL pgbuild buildstatus %PGB_ID% ^| sed -n "/^\s*pending:.*android.*/p"') DO (
	ECHO Waiting 5 seconds for build to be ready
	TIMEOUT /T 5 > NUL
	GOTO :DOWNLOAD_WAIT
)
ECHO.
ECHO DOWNLOAD READY
GOTO :EOF

:DOWNLOAD
CALL :UPDATE_ID
CALL :DOWNLOAD_WAIT
ECHO.
ECHO DOWNLOADING
ECHO.
CALL pgbuild download %PGB_ID% android
ECHO.
ECHO COMPLETED
CALL :UPDATE_APK
GOTO :EOF


:COPYOVERRIDES
ECHO COPYING OVERRIDES
ECHO.
CALL XCOPY "Libs overrides\*" "%CURRENT_DRIVE%\Libs\" /S /Y
GOTO :EOF

:BUILDRES
ECHO BUILDING RESOURCES
ECHO.
CALL cordova-gen
GOTO :EOF


:INITPLATFORM
ECHO INITIALIZE PLATFORM
ECHO.

IF "%CD%"=="%ANDROID_HOME%" (
	ECHO INCORRECT PROJECT DIR
	GOTO :EOF
)

IF EXIST "platforms\" ( RD /S /Q "platforms\" )
IF EXIST "plugins\" ( RD /S /Q "plugins\" )

SETLOCAL
SET PATTERN="/^\s*<gap:plugin /s/.*name=['""]\([^'""]*\)['""].*$/\1/gp"
FOR /F %%A IN ('sed -n -e %PATTERN% config.xml') DO ECHO DOWNLOADING: %%A & CALL phonegap plugin add %%A > NUL
ENDLOCAL

ECHO.
ECHO ADDING ANDROID PLATFORM
ECHO.
CALL phonegap platform add android

GOTO :EOF

:SERVEAPK
ECHO SERVING APK
START "Phonegap Live Server" phonegap serve --no-autoreload
GOTO :EOF

:BUILDAPK
ECHO BUILD APK
CALL phonegap build android --%APK_MODE% --verbose
COPY "platforms\android\build\outputs\apk\android-debug.apk" %APK%
CALL :UPDATE_APK
GOTO :EOF


:INSTAPK
ECHO UNINSTALL APK
CALL adb uninstall %APK_PACKAGE%
ECHO.
ECHO INSTALL APK
CALL adb install -r %APK%
GOTO :EOF


:RUNAPK
ECHO RUN APK
ECHO PACKAGE: %APK_PACKAGE%/%APK_ACTIVITY%
ECHO.
CALL adb shell am start -S -n %APK_PACKAGE%/%APK_ACTIVITY%
GOTO :EOF


:COMMAND
SET COMMAND=
SET /P COMMAND=%CD%^>
ECHO.
CALL %COMMAND%
SET COMMAND=
GOTO :EOF


:PROMPT
ECHO OPEN COMMAND PROMPT
START "Libs Prompt" /I "%~d0\Libs\Setup.bat"
:: "%~d0\Libs\setup.bat"
GOTO :EOF

:GITGUI
ECHO RUN GIT GUI
CMD /C START /MIN Git gui
GOTO :EOF


:HELP
ECHO Make sure to change the mode of the apk to match that on phonegap build.
ECHO.
ECHO Can enter multiple values when prefixing with '-' (i.e. -890)
ECHO EXAMPLE: -BUD90 (Builds resources, uploads, downloads, installs and runs on device)
GOTO :EOF

:RESTART
ENDLOCAL
CMD /C %CURRENT_FILE%

:QUIT
EXIT
