::Set online server address
if not defined onlineServer set "onlineServer=dnascanner.dynv6.net:3000"

::Check if server is up
set "onlineServerStatus="
for /f "delims=" %%F in ('curl !onlineServer!/debug/check -s') do set "onlineServerStatus=%%F"
if defined onlineServerStatus (
      echo %translation.online.connected%
      sleep 1 s
) else (
      echo %translation.online.failed%
      sleep 3 s
      exit /b
)

::Ask for player name and login
:getOnlineName
set "onlineName="
echo %translation.online.promptName%
if not exist tabcomplete\ ( md tabcomplete )
del /f /q tabcomplete\*
echo Tabcomplete asset>tabcomplete\CANCEL
pushd tabcomplete
set /p "onlineName=> "
popd

if not defined onlineName (
      cls
      echo %translation.online.promptNameError%
      goto getOnlineName
)

if "!onlineName!" equ "CANCEL" (
      echo %translation.online.cancelling%
      sleep 2 s
      exit /b
)

:tryLogin
for /f "delims=" %%A in ('curl !onlineServer!/user/login/!onlineName! -s') do set "onlineLogin=%%A"
set "onlineLogin=!onlineLogin:"=!"
if "!onlineLogin!" equ "userExist" (
      cls
      echo %translation.online.userExist%
      sleep 3 s
      goto getOnlineName
)

echo %translation.online.loggedIn%
sleep 1 s

set /a "searchingAnimation=1"
:checkSearching
for /f "delims=" %%A in ('curl !onlineServer!/user/status/!onlineLogin! -s') do set "onlineStatus=%%A"
if "!onlineStatus!" equ "searching" (
      set /a "searchingAnimation+=1"
      if !searchingAnimation! gtr 3 ( set /a "searchingAnimation=1" )
      cls
      for %%A in (!searchingAnimation!) do (
            for /l %%B in (1,1,14) do (
                  echo %colorYellow%!translation.online.searchingDot%%A.%%B!%colorReset%
            )
      )
      for /l %%A in (1,1,2) do (
            echo.
      )
      echo !onlineStatus! - %time:~0,-3%
      sleep 2 s
      goto checkSearching
)

::Set default values
:buildGame
for /l %%A in (1,1,9) do set /a "gameField[%%A]=0"
set "gamePlaceSelection=5"
set "goDirectToDisplay=true"

:getBoard
for /f "delims=*" %%F in ('curl !onlineServer!/session/getboard/!onlineLogin! -s') do (
      set "boardGet=%%F"
      set "boardGet=!boardGet:[=!"
      set "boardGet=!boardGet:]=!"
      set "boardGet=!boardGet:"=!"
      set "boardGet=!boardGet:,= !"
)

set /a "boardGetCounter=0"
for %%A in (!boardGet!) do (
      set /a "boardGetCounter+=1"
      set /a "gameField[!boardGetCounter!]=%%A"
)

:getUserTurn
for /f "delims=*" %%F in ('curl !onlineServer!/session/getturn/!onlineLogin! -s') do (
      set "turnGet=%%F"
)

if "!goDirectToDisplay!" equ "true" (
      set "goDirectToDisplay=false"
      goto display
)

:getInput
if "!turnGet!" equ "you" (
      choice /c:wsadf /n >nul
      if !errorlevel! equ 1 if !gamePlaceSelection! geq 4 set /a "gamePlaceSelection-=3"
      if !errorlevel! equ 2 if !gamePlaceSelection! leq 6 set /a "gamePlaceSelection+=3"
      if !errorlevel! equ 3 if not !gamePlaceSelection! equ 1 if not !gamePlaceSelection! equ 4 if not !gamePlaceSelection! equ 7 set /a "gamePlaceSelection-=1"
      if !errorlevel! equ 4 if not !gamePlaceSelection! equ 3 if not !gamePlaceSelection! equ 6 if not !gamePlaceSelection! equ 9 set /a "gamePlaceSelection+=1"
      ::Move Cursor Faster
      if not !errorlevel! equ 5 set "moveCursor=true"
      if !errorlevel! equ 5 if !gameField[%gamePlaceSelection%]! equ 0 for /f "delims=" %%A in ('curl !onlineServer!/session/place/!onlineLogin!/!gamePlaceSelection! -s') do (
            set "onlinePlace=%%A"
            set "goDirectToDisplay=true"
            goto getBoard
      )
)

:display
set /a "displayCounter=1"
cls
for /l %%A in (1,1,6) do ( echo !tttHeader%%A! )
for /l %%A in (1,1,2) do ( echo. )
echo ----------------------------
for /l %%A in (1,1,3) do (
            set /a "rowFirstField=%%A*3-2" && for %%C in (!rowFirstField!) do ( set "rowFirstField=!gameField[%%C]!" )
            set /a "rowSecondField=%%A*3-1" && for %%C in (!rowSecondField!) do ( set "rowSecondField=!gameField[%%C]!" )
            set /a "rowThirdField=%%A*3" && for %%C in (!rowThirdField!) do ( set "rowThirdField=!gameField[%%C]!" )

            if !rowFirstField! equ 0 if not !gamePlaceSelection! equ !displayCounter!  (
                  set "displayRow1=!playerSign_1!"
                  set "displayRow2=!playerSign_2!"
                  set "displayRow3=!playerSign_3!"
            ) else (
                  if "!turnGet!" equ "you" (
                        set "displayRow1=%colorYellow%!playerSign-1!%colorReset%"
                        set "displayRow2=%colorYellow%!playerSign-2!%colorReset%"
                        set "displayRow3=%colorYellow%!playerSign-3!%colorReset%"
                  ) else (
                        set "displayRow1=!playerSign-1!"
                        set "displayRow2=!playerSign-2!"
                        set "displayRow3=!playerSign-3!"
                  )
            )

            if !rowFirstField! equ 1 if not !gamePlaceSelection! equ !displayCounter! (
                  set "displayRow1=!playerSignX1!"
                  set "displayRow2=!playerSignX2!"
                  set "displayRow3=!playerSignX3!"
            ) else (
                  if "!turnGet!" equ "you" (
                        set "displayRow1=%colorYellow%!playerSignX1!%colorReset%"
                        set "displayRow2=%colorYellow%!playerSignX2!%colorReset%"
                        set "displayRow3=%colorYellow%!playerSignX3!%colorReset%"
                  ) else (
                        set "displayRow1=!playerSignX1!"
                        set "displayRow2=!playerSignX2!"
                        set "displayRow3=!playerSignX3!"
                  )
            )

            if !rowFirstField! equ 2 if not !gamePlaceSelection! equ !displayCounter! (
                  set "displayRow1=!playerSignO1!"
                  set "displayRow2=!playerSignO2!"
                  set "displayRow3=!playerSignO3!"
            ) else (
                  if "!turnGet!" equ "you" (
                        set "displayRow1=%colorYellow%!playerSignO1!%colorReset%"
                        set "displayRow2=%colorYellow%!playerSignO2!%colorReset%"
                        set "displayRow3=%colorYellow%!playerSignO3!%colorReset%"
                  ) else (
                        set "displayRow1=!playerSignO1!"
                        set "displayRow2=!playerSignO2!"
                        set "displayRow3=!playerSignO3!"
                  )
            )
            set /a "displayCounter+=1"

            if !rowSecondField! equ 0 if not !gamePlaceSelection! equ !displayCounter!  (
                  set "displayRow1=!displayRow1! | !playerSign_1!"
                  set "displayRow2=!displayRow2! | !playerSign_2!"
                  set "displayRow3=!displayRow3! | !playerSign_3!"
            ) else (
                  if "!turnGet!" equ "you" (
                        set "displayRow1=!displayRow1! | %colorYellow%!playerSign-1!%colorReset%"
                        set "displayRow2=!displayRow2! | %colorYellow%!playerSign-2!%colorReset%"
                        set "displayRow3=!displayRow3! | %colorYellow%!playerSign-3!%colorReset%"
                  ) else (
                        set "displayRow1=!displayRow1! | !playerSign-1!"
                        set "displayRow2=!displayRow2! | !playerSign-2!"
                        set "displayRow3=!displayRow3! | !playerSign-3!"
                  )
            )

            if !rowSecondField! equ 1 if not !gamePlaceSelection! equ !displayCounter! (
                  set "displayRow1=!displayRow1! | !playerSignX1!"
                  set "displayRow2=!displayRow2! | !playerSignX2!"
                  set "displayRow3=!displayRow3! | !playerSignX3!"
            ) else (
                  if "!turnGet!" equ "you" (
                        set "displayRow1=!displayRow1! | %colorYellow%!playerSignX1!%colorReset%"
                        set "displayRow2=!displayRow2! | %colorYellow%!playerSignX2!%colorReset%"
                        set "displayRow3=!displayRow3! | %colorYellow%!playerSignX3!%colorReset%"
                  ) else (
                        set "displayRow1=!displayRow1! | !playerSignX1!"
                        set "displayRow2=!displayRow2! | !playerSignX2!"
                        set "displayRow3=!displayRow3! | !playerSignX3!"
                  )
            )

            if !rowSecondField! equ 2 if not !gamePlaceSelection! equ !displayCounter! (
                  set "displayRow1=!displayRow1! | !playerSignO1!"
                  set "displayRow2=!displayRow2! | !playerSignO2!"
                  set "displayRow3=!displayRow3! | !playerSignO3!"
            ) else (
                  if "!turnGet!" equ "you" (
                        set "displayRow1=!displayRow1! | %colorYellow%!playerSignO1!%colorReset%"
                        set "displayRow2=!displayRow2! | %colorYellow%!playerSignO2!%colorReset%"
                        set "displayRow3=!displayRow3! | %colorYellow%!playerSignO3!%colorReset%"
                  ) else (
                        set "displayRow1=!displayRow1! | !playerSignO1!"
                        set "displayRow2=!displayRow2! | !playerSignO2!"
                        set "displayRow3=!displayRow3! | !playerSignO3!"
                  )
            )
            set /a "displayCounter+=1"

            if !rowThirdField! equ 0 if not !gamePlaceSelection! equ !displayCounter!  (
                  set "displayRow1=!displayRow1! | !playerSign_1!"
                  set "displayRow2=!displayRow2! | !playerSign_2!"
                  set "displayRow3=!displayRow3! | !playerSign_3!"
            ) else (
                  if "!turnGet!" equ "you" (
                        set "displayRow1=!displayRow1! | %colorYellow%!playerSign-1!%colorReset%"
                        set "displayRow2=!displayRow2! | %colorYellow%!playerSign-2!%colorReset%"
                        set "displayRow3=!displayRow3! | %colorYellow%!playerSign-3!%colorReset%"
                  ) else (
                        set "displayRow1=!displayRow1! | !playerSign-1!"
                        set "displayRow2=!displayRow2! | !playerSign-2!"
                        set "displayRow3=!displayRow3! | !playerSign-3!"
                  )
            )

            if !rowThirdField! equ 1 if not !gamePlaceSelection! equ !displayCounter! (
                  set "displayRow1=!displayRow1! | !playerSignX1!"
                  set "displayRow2=!displayRow2! | !playerSignX2!"
                  set "displayRow3=!displayRow3! | !playerSignX3!"
            ) else (
                  if "!turnGet!" equ "you" (
                        set "displayRow1=!displayRow1! | %colorYellow%!playerSignX1!%colorReset%"
                        set "displayRow2=!displayRow2! | %colorYellow%!playerSignX2!%colorReset%"
                        set "displayRow3=!displayRow3! | %colorYellow%!playerSignX3!%colorReset%"
                  ) else (
                        set "displayRow1=!displayRow1! | !playerSignX1!"
                        set "displayRow2=!displayRow2! | !playerSignX2!"
                        set "displayRow3=!displayRow3! | !playerSignX3!"
                  )
            )

            if !rowThirdField! equ 2 if not !gamePlaceSelection! equ !displayCounter! (
                  set "displayRow1=!displayRow1! | !playerSignO1!"
                  set "displayRow2=!displayRow2! | !playerSignO2!"
                  set "displayRow3=!displayRow3! | !playerSignO3!"
            ) else (
                  if "!turnGet!" equ "you" (
                        set "displayRow1=!displayRow1! | %colorYellow%!playerSignO1!%colorReset%"
                        set "displayRow2=!displayRow2! | %colorYellow%!playerSignO2!%colorReset%"
                        set "displayRow3=!displayRow3! | %colorYellow%!playerSignO3!%colorReset%"
                  ) else (
                        set "displayRow1=!displayRow1! | !playerSignO1!"
                        set "displayRow2=!displayRow2! | !playerSignO2!"
                        set "displayRow3=!displayRow3! | !playerSignO3!"
                  )
            )
            set /a "displayCounter+=1"

            if %%A equ 1 (
                  set "displayRow1=| !displayRow1! |"
                  set "displayRow2=| !displayRow2! |"
                  set "displayRow3=| !displayRow3! |"
            )

            if %%A equ 2 (
                  set "displayRow1=| !displayRow1! |"
                  if "!turnGet!" equ "you" set "displayRow2=| !displayRow2! | %translation.online.turn.you%"
                  if not "!turnGet!" equ "you" set "displayRow2=| !displayRow2! | %translation.online.turn.opponent%"
                  set "displayRow3=| !displayRow3! |"
            )

            if %%A equ 3 (
                  set "displayRow1=| !displayRow1! |"
                  set "displayRow2=| !displayRow2! |"
                  set "displayRow3=| !displayRow3! |"
            )


      for /l %%A in (1,1,3) do (
            echo !displayRow%%A!
      )
      echo ----------------------------
)

if "!moveCursor!" equ "true" (
      set "moveCursor=false"
      goto getInput
)

for /f "delims=" %%A in ('curl !onlineServer!/session/getwinner/!onlineLogin! -s') do (
      set "winner=%%A"
      if not "!winner!" equ "noWinner" (
            goto displayWon
      )
)

if not "!turnGet!" equ "you" (
      set "goDirectToDisplay=true"
      goto getBoard
)

goto getBoard

:displayWon
if "!winner!" equ "tie" (
      cls
      echo !translation.offline.win.tie6!
      sleep 50 ms
      cls
      echo !translation.offline.win.tie5!
      echo !translation.offline.win.tie6!
      sleep 50 ms
      cls
      echo !translation.offline.win.tie4!
      echo !translation.offline.win.tie5!
      echo !translation.offline.win.tie6!
      sleep 50 ms
      cls
      echo !translation.offline.win.tie3!
      echo !translation.offline.win.tie4!
      echo !translation.offline.win.tie5!
      echo !translation.offline.win.tie6!
      sleep 50 ms
      cls
      echo !translation.offline.win.tie2!
      echo !translation.offline.win.tie3!
      echo !translation.offline.win.tie4!
      echo !translation.offline.win.tie5!
      echo !translation.offline.win.tie6!
      sleep 50 ms
      cls
      echo !translation.offline.win.tie1!
      echo !translation.offline.win.tie2!
      echo !translation.offline.win.tie3!
      echo !translation.offline.win.tie4!
      echo !translation.offline.win.tie5!
      echo !translation.offline.win.tie6!
) else (
      cls
      echo !winner! Won the Game^!
)

for /l %%. in (1,1,2) do echo.
echo %translation.offline.controls%
choice /c:re /n >nul

if "!errorlevel!" equ "1" (
      for /f "delims=" %%A in ('curl !onlineServer!/user/logout/!onlineLogin! -s') do ( set "onlineLogout=%%A" )
      goto tryLogin
)

if "!errorlevel!" equ "2" (
      for /f "delims=" %%A in ('curl !onlineServer!/user/logout/!onlineLogin! -s') do ( set "onlineLogout=%%A" )
      exit /b
)

pause >nul