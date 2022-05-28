@echo off
set "translation.game.crash=Game crashed^^^!"
setlocal enabledelayedexpansion
setlocal enableextensions
set /a "gameVersion=1"
set /a "setCodes=1"
chcp 65001 >nul
set "gameDirectory=%~dp0"

::Set game codes
if !setCodes! equ 1 (
      ::Colors
      if !setCodes! equ 1 (
            ::Foreground colors
            set "colorBlack=[30m"
            set "colorRed=[31m"
            set "colorGreen=[32m"
            set "colorYellow=[33m"
            set "colorBlue=[34m"
            set "colorMagenta=[35m"
            set "colorCyan=[36m"
            set "colorWhite=[37m"

            ::Background colors
            set "bgColorBlack=[40m"
            set "bgColorRed=[41m"
            set "bgColorGreen=[42m"
            set "bgColorYellow=[43m"
            set "bgColorBlue=[44m"
            set "bgColorMagenta=[45m"
            set "bgColorCyan=[46m"
            set "bgColorWhite=[47m"

            ::Strong Foreground colors
            set "colorStrongBlack=[90m"
            set "colorStrongRed=[91m"
            set "colorStrongGreen=[92m"
            set "colorStrongYellow=[93m"
            set "colorStrongBlue=[94m"
            set "colorStrongMagenta=[95m"
            set "colorStrongCyan=[96m"
            set "colorStrongWhite=[97m"

            ::Strong Background colors
            set "bgColorStrongBlack=[100m"
            set "bgColorStrongRed=[101m"
            set "bgColorStrongGreen=[102m"
            set "bgColorStrongYellow=[103m"
            set "bgColorStrongBlue=[104m"
            set "bgColorStrongMagenta=[105m"
            set "bgColorStrongCyan=[106m"
            set "bgColorStrongWhie=[107m"

            ::Full color
            set "fullColorBlack=!colorBlack!!bgColorBlack!"
            set "fullColorRed=!colorRed!!bgColorRed!"
            set "fullColorGreen=!colorGreen!!bgColorGreen!"
            set "fullColorYellow=!colorYellow!!bgColorYellow!"
            set "fullColorBlue=!colorBlue!!bgColorBlue!"
            set "fullColorMagenta=!colorMagenta!!bgColorMagenta!"
            set "fullColorCyan=!colorCyan!!bgColorCyan!"
            set "fullColorWhite=!colorWhite!!bgColorWhite!"

            ::Strong Full color
            set "fullColorStrongBlack=!colorStrongBlack!!bgColorStrongBlack!"
            set "fullColorStrongRed=!colorStrongRed!!bgColorStrongRed!"
            set "fullColorStrongGreen=!colorStrongGreen!!bgColorStrongGreen!"
            set "fullColorStrongYellow=!colorStrongYellow!!bgColorStrongYellow!"
            set "fullColorStrongBlue=!colorStrongBlue!!bgColorStrongBlue!"
            set "fullColorStrongMagenta=!colorStrongMagenta!!bgColorStrongMagenta!"
            set "fullColorStrongCyan=!colorStrongCyan!!bgColorStrongCyan!"
            set "fullColorStrongWhite=!colorStrongWhite!!bgColorStrongWhite!"

            ::Reset
            set "colorReset=[0m"
      )
)

::Get config
if exist config.cmd call config.cmd

::Define undefined variables
if not defined userLanguage set "userLanguage=english"

::Read language
:getLang
if exist lang\!userLanguage!.cmd ( call lang\!userLanguage!.cmd ) else (
      echo !userLanguage! is not available
      set "userLanguage=english"
      goto getLang
)

::Set title
title %translation.main.title%

::Get start argument
if not "%~1" equ "" goto promptUserName

::Fullscreen recommendation
for /l %%A in (1,1,3) do echo !translation.main.fullscreen%%A!

sleep 2 s
for /l %%A in (1,1,3) do echo.

:promptUserName
if not defined playerName (
      echo %translation.game.greeting%
      set /p "playerName=> "
      cls
      if defined playerName (
            echo %translation.game.greeting2%
            sleep 2 s
      ) else (
            goto promptUserName
      )
)

:menu
call menuMain.cmd %~1

echo %colorYellow%[%time:~0,-3%]%colorReset% %colorRed%!translation.game.crash!%colorReset%
pause >nul