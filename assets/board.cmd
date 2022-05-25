::Set default values
:buildGame
for /l %%A in (1,1,9) do set /a "gameField[%%A]=0"
set /a "gamePlaceSelection=5"
set /a "playerTurn=1"
set /a "winningPlayer=0"
for /l %%A in (1,1,3) do set /a "winningField[%%A]=0"
set /a "end=0"

goto display

:checkBoard
::Check for win
for %%A in ( 4 5 6 ) do (
      set "fieldAbove=" && set /a "fieldAbove=%%A-3" && for %%B in (!fieldAbove!) do ( set "fieldAbove=!gameField[%%B]!" )
      set "fieldBelow=" && set /a "fieldBelow=%%A+3" && for %%B in (!fieldBelow!) do ( set "fieldBelow=!gameField[%%B]!" )

      if !gameField[%%A]! neq 0 if !gameField[%%A]! equ !fieldAbove! if !gameField[%%A]! equ !fieldBelow! (
            set /a "winningField[1]=%%A+3"
            set /a "winningField[2]=%%A-3"
            set /a "winningField[3]=%%A"
            set /a "end=1, winningPlayer=!gameField[%%A]!"
      )
)

for %%A in ( 2 5 8 ) do (
      set "fieldLeft=" && set /a "fieldLeft=%%A-1" && for %%B in (!fieldLeft!) do ( set "fieldLeft=!gameField[%%B]!" )
      set "fieldRight=" && set /a "fieldRight=%%A+1" && for %%B in (!fieldRight!) do ( set "fieldRight=!gameField[%%B]!" )

      if !gameField[%%A]! neq 0 if !gameField[%%A]! equ !fieldLeft! if !gameField[%%A]! equ !fieldRight! (
            set /a "winningField[1]=%%A+1"
            set /a "winningField[2]=%%A-1"
            set /a "winningField[3]=%%A"
            set /a "end=1, winningPlayer=!gameField[%%A]!"
      )
)

if !gameField[5]! neq 0 if !gameField[5]! equ !gameField[1]! if !gameField[5]! equ !gameField[9]! (
      set /a "winningField[1]=1"
      set /a "winningField[2]=5"
      set /a "winningField[3]=9"
      set /a "end=1, winningPlayer=!gameField[5]!"
)

if !gameField[5]! neq 0 if !gameField[5]! equ !gameField[3]! if !gameField[5]! equ !gameField[7]! (
      set /a "winningField[1]=3"
      set /a "winningField[2]=5"
      set /a "winningField[3]=7"
      set /a "end=1, winningPlayer=!gameField[5]!"
)

::Check if field is full
if !end! equ 0 (
      set /a "emptyFields=0"
      for /l %%A in (1,1,9) do (
            if !gameField[%%A]! equ 0 (
                  set /a "emptyFields+=1"
            )
      )
)

if !emptyFields! equ 0 set /a "end=1, winningPlayer=0"

::End game
if !end! equ 1 (
      sleep 20 ms
      goto displayWon
)

:getInput
choice /c:wsadf /n >nul
if !errorlevel! equ 1 if !gamePlaceSelection! geq 4 set /a "gamePlaceSelection-=3"
if !errorlevel! equ 2 if !gamePlaceSelection! leq 6 set /a "gamePlaceSelection+=3"
if !errorlevel! equ 3 if not !gamePlaceSelection! equ 1 if not !gamePlaceSelection! equ 4 if not !gamePlaceSelection! equ 7 set /a "gamePlaceSelection-=1"
if !errorlevel! equ 4 if not !gamePlaceSelection! equ 3 if not !gamePlaceSelection! equ 6 if not !gamePlaceSelection! equ 9 set /a "gamePlaceSelection+=1"
if !errorlevel! equ 5 if !gameField[%gamePlaceSelection%]! equ 0 set /a "gameField[%gamePlaceSelection%]=!playerTurn!" && set /a "playerTurn=!playerTurn! %% 2 + 1"

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

            if !rowFirstField! equ 0 if not !gamePlaceSelection! equ !displayCounter! if ! (
                  set "displayRow1=!playerSign_1!"
                  set "displayRow2=!playerSign_2!"
                  set "displayRow3=!playerSign_3!"
            ) else (
                  set "displayRow1=%colorYellow%!playerSign-1!%colorReset%"
                  set "displayRow2=%colorYellow%!playerSign-2!%colorReset%"
                  set "displayRow3=%colorYellow%!playerSign-3!%colorReset%"
            )

            if !rowFirstField! equ 1 if not !gamePlaceSelection! equ !displayCounter! (
                  set "displayRow1=!playerSignX1!"
                  set "displayRow2=!playerSignX2!"
                  set "displayRow3=!playerSignX3!"
            ) else (
                  set "displayRow1=%colorYellow%!playerSignX1!%colorReset%"
                  set "displayRow2=%colorYellow%!playerSignX2!%colorReset%"
                  set "displayRow3=%colorYellow%!playerSignX3!%colorReset%"
            )

            if !rowFirstField! equ 2 if not !gamePlaceSelection! equ !displayCounter! (
                  set "displayRow1=!playerSignO1!"
                  set "displayRow2=!playerSignO2!"
                  set "displayRow3=!playerSignO3!"
            ) else (
                  set "displayRow1=%colorYellow%!playerSignO1!%colorReset%"
                  set "displayRow2=%colorYellow%!playerSignO2!%colorReset%"
                  set "displayRow3=%colorYellow%!playerSignO3!%colorReset%"
            )
            set /a "displayCounter+=1"

            if !rowSecondField! equ 0 if not !gamePlaceSelection! equ !displayCounter! if ! (
                  set "displayRow1=!displayRow1! | !playerSign_1!"
                  set "displayRow2=!displayRow2! | !playerSign_2!"
                  set "displayRow3=!displayRow3! | !playerSign_3!"
            ) else (
                  set "displayRow1=!displayRow1! | %colorYellow%!playerSign-1!%colorReset%"
                  set "displayRow2=!displayRow2! | %colorYellow%!playerSign-2!%colorReset%"
                  set "displayRow3=!displayRow3! | %colorYellow%!playerSign-3!%colorReset%"
            )

            if !rowSecondField! equ 1 if not !gamePlaceSelection! equ !displayCounter! (
                  set "displayRow1=!displayRow1! | !playerSignX1!"
                  set "displayRow2=!displayRow2! | !playerSignX2!"
                  set "displayRow3=!displayRow3! | !playerSignX3!"
            ) else (
                  set "displayRow1=!displayRow1! | %colorYellow%!playerSignX1!%colorReset%"
                  set "displayRow2=!displayRow2! | %colorYellow%!playerSignX2!%colorReset%"
                  set "displayRow3=!displayRow3! | %colorYellow%!playerSignX3!%colorReset%"
            )

            if !rowSecondField! equ 2 if not !gamePlaceSelection! equ !displayCounter! (
                  set "displayRow1=!displayRow1! | !playerSignO1!"
                  set "displayRow2=!displayRow2! | !playerSignO2!"
                  set "displayRow3=!displayRow3! | !playerSignO3!"
            ) else (
                  set "displayRow1=!displayRow1! | %colorYellow%!playerSignO1!%colorReset%"
                  set "displayRow2=!displayRow2! | %colorYellow%!playerSignO2!%colorReset%"
                  set "displayRow3=!displayRow3! | %colorYellow%!playerSignO3!%colorReset%"
            )
            set /a "displayCounter+=1"

            if !rowThirdField! equ 0 if not !gamePlaceSelection! equ !displayCounter! if ! (
                  set "displayRow1=!displayRow1! | !playerSign_1!"
                  set "displayRow2=!displayRow2! | !playerSign_2!"
                  set "displayRow3=!displayRow3! | !playerSign_3!"
            ) else (
                  set "displayRow1=!displayRow1! | %colorYellow%!playerSign-1!%colorReset%"
                  set "displayRow2=!displayRow2! | %colorYellow%!playerSign-2!%colorReset%"
                  set "displayRow3=!displayRow3! | %colorYellow%!playerSign-3!%colorReset%"
            )

            if !rowThirdField! equ 1 if not !gamePlaceSelection! equ !displayCounter! (
                  set "displayRow1=!displayRow1! | !playerSignX1!"
                  set "displayRow2=!displayRow2! | !playerSignX2!"
                  set "displayRow3=!displayRow3! | !playerSignX3!"
            ) else (
                  set "displayRow1=!displayRow1! | %colorYellow%!playerSignX1!%colorReset%"
                  set "displayRow2=!displayRow2! | %colorYellow%!playerSignX2!%colorReset%"
                  set "displayRow3=!displayRow3! | %colorYellow%!playerSignX3!%colorReset%"
            )

            if !rowThirdField! equ 2 if not !gamePlaceSelection! equ !displayCounter! (
                  set "displayRow1=!displayRow1! | !playerSignO1!"
                  set "displayRow2=!displayRow2! | !playerSignO2!"
                  set "displayRow3=!displayRow3! | !playerSignO3!"
            ) else (
                  set "displayRow1=!displayRow1! | %colorYellow%!playerSignO1!%colorReset%"
                  set "displayRow2=!displayRow2! | %colorYellow%!playerSignO2!%colorReset%"
                  set "displayRow3=!displayRow3! | %colorYellow%!playerSignO3!%colorReset%"
            )
            set /a "displayCounter+=1"

            if %%A equ 1 (
                  set "displayRow1=| !displayRow1! |"
                  set "displayRow2=| !displayRow2! |"
                  set "displayRow3=| !displayRow3! |"
            )

            if %%A equ 2 (
                  set "displayRow1=| !displayRow1! |"
                  set "displayRow2=| !displayRow2! | %translation.game.turn%"
                  set "displayRow3=| !displayRow3! |"
            )

            if %%A equ 3 (
                  set "displayRow1=| !displayRow1! |"
                  set "displayRow2=| !displayRow2! |"
                  set "displayRow3=| !displayRow3! |"
            )

            if !playerTurn! equ 0 (
                  set "playerTurnSign=Tie"
            )

            if !playerTurn! equ 1 (
                  set "playerTurnSign=X"
            )

            if !playerTurn! equ 2 (
                  set "playerTurnSign=O"
            )


      for /l %%A in (1,1,3) do (
            echo !displayRow%%A!
      )
      echo ----------------------------
)
goto checkBoard

:displayWon
for /l %%. in (1,1,3) do (
set /a "displayCounter=1"
cls
for /l %%A in (1,1,6) do ( echo !tttHeader%%A! )
for /l %%A in (1,1,2) do ( echo. )
echo ----------------------------
for /l %%A in (1,1,3) do (
            set /a "rowFirstField=%%A*3-2" && for %%C in (!rowFirstField!) do ( set "rowFirstField=!gameField[%%C]!" )
            set /a "rowSecondField=%%A*3-1" && for %%C in (!rowSecondField!) do ( set "rowSecondField=!gameField[%%C]!" )
            set /a "rowThirdField=%%A*3" && for %%C in (!rowThirdField!) do ( set "rowThirdField=!gameField[%%C]!" )

            set /a "fieldIsWinningField=0"
            set done=
            for /l %%A in (1,1,3) do if !displayCounter! equ !winningField[%%A]! if not defined done (
                  set /a "fieldIsWinningField=1"
                  set "done=break"
            )

            if !rowFirstField! equ 0 (
                  set "displayRow1=!playerSign_1!"
                  set "displayRow2=!playerSign_2!"
                  set "displayRow3=!playerSign_3!"
            )

            if !rowFirstField! equ 1 if !fieldIsWinningField! equ 1 (
                  set "displayRow1=%colorStrongGreen%!playerSignX1!%colorReset%"
                  set "displayRow2=%colorStrongGreen%!playerSignX2!%colorReset%"
                  set "displayRow3=%colorStrongGreen%!playerSignX3!%colorReset%"
            ) else (
                  set "displayRow1=!playerSignX1!"
                  set "displayRow2=!playerSignX2!"
                  set "displayRow3=!playerSignX3!"
            )

            if !rowFirstField! equ 2 if !fieldIsWinningField! equ 1 (
                  set "displayRow1=%colorStrongGreen%!playerSignO1!%colorReset%"
                  set "displayRow2=%colorStrongGreen%!playerSignO2!%colorReset%"
                  set "displayRow3=%colorStrongGreen%!playerSignO3!%colorReset%"
            ) else (
                  set "displayRow1=!playerSignO1!"
                  set "displayRow2=!playerSignO2!"
                  set "displayRow3=!playerSignO3!"
            )
            set /a "displayCounter+=1"
            set /a "fieldIsWinningField=0"
            set done=
            for /l %%A in (1,1,3) do if !displayCounter! equ !winningField[%%A]! if not defined done (
                  set /a "fieldIsWinningField=1"
                  set "done=break"
            )

            if !rowSecondField! equ 0 (
                  set "displayRow1=!displayRow1! | !playerSign_1!"
                  set "displayRow2=!displayRow2! | !playerSign_2!"
                  set "displayRow3=!displayRow3! | !playerSign_3!"
            )

            if !rowSecondField! equ 1 if not !fieldIsWinningField! equ 1 (
                  set "displayRow1=!displayRow1! | !playerSignX1!"
                  set "displayRow2=!displayRow2! | !playerSignX2!"
                  set "displayRow3=!displayRow3! | !playerSignX3!"
            ) else (
                  set "displayRow1=!displayRow1! | %colorStrongGreen%!playerSignX1!%colorReset%"
                  set "displayRow2=!displayRow2! | %colorStrongGreen%!playerSignX2!%colorReset%"
                  set "displayRow3=!displayRow3! | %colorStrongGreen%!playerSignX3!%colorReset%"
            )

            if !rowSecondField! equ 2 if not !fieldIsWinningField! equ 1 (
                  set "displayRow1=!displayRow1! | !playerSignO1!"
                  set "displayRow2=!displayRow2! | !playerSignO2!"
                  set "displayRow3=!displayRow3! | !playerSignO3!"
            ) else (
                  set "displayRow1=!displayRow1! | %colorStrongGreen%!playerSignO1!%colorReset%"
                  set "displayRow2=!displayRow2! | %colorStrongGreen%!playerSignO2!%colorReset%"
                  set "displayRow3=!displayRow3! | %colorStrongGreen%!playerSignO3!%colorReset%"
            )
            set /a "displayCounter+=1"
            set /a "fieldIsWinningField=0"
            set done=
            for /l %%A in (1,1,3) do if !displayCounter! equ !winningField[%%A]! if not defined done (
                  set /a "fieldIsWinningField=1"
                  set "done=break"
            )

            if !rowThirdField! equ 0 (
                  set "displayRow1=!displayRow1! | !playerSign_1!"
                  set "displayRow2=!displayRow2! | !playerSign_2!"
                  set "displayRow3=!displayRow3! | !playerSign_3!"
            )

            if !rowThirdField! equ 1 if not !fieldIsWinningField! equ 1 (
                  set "displayRow1=!displayRow1! | !playerSignX1!"
                  set "displayRow2=!displayRow2! | !playerSignX2!"
                  set "displayRow3=!displayRow3! | !playerSignX3!"
            ) else (
                  set "displayRow1=!displayRow1! | %colorStrongGreen%!playerSignX1!%colorReset%"
                  set "displayRow2=!displayRow2! | %colorStrongGreen%!playerSignX2!%colorReset%"
                  set "displayRow3=!displayRow3! | %colorStrongGreen%!playerSignX3!%colorReset%"
            )

            if !rowThirdField! equ 2 if not !fieldIsWinningField! equ 1 (
                  set "displayRow1=!displayRow1! | !playerSignO1!"
                  set "displayRow2=!displayRow2! | !playerSignO2!"
                  set "displayRow3=!displayRow3! | !playerSignO3!"
            ) else (
                  set "displayRow1=!displayRow1! | %colorStrongGreen%!playerSignO1!%colorReset%"
                  set "displayRow2=!displayRow2! | %colorStrongGreen%!playerSignO2!%colorReset%"
                  set "displayRow3=!displayRow3! | %colorStrongGreen%!playerSignO3!%colorReset%"
            )
            set /a "displayCounter+=1"

            if %%A equ 1 (
                  set "displayRow1=| !displayRow1! |"
                  set "displayRow2=| !displayRow2! |"
                  set "displayRow3=| !displayRow3! |"
            )

            if %%A equ 2 (
                  set "displayRow1=| !displayRow1! |"
                  set "displayRow2=| !displayRow2! |"
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

sleep 300 ms

set /a "displayCounter=1"
cls
for /l %%A in (1,1,6) do ( echo !tttHeader%%A! )
for /l %%A in (1,1,2) do ( echo. )
echo ----------------------------
for /l %%A in (1,1,3) do (
            set /a "rowFirstField=%%A*3-2" && for %%C in (!rowFirstField!) do ( set "rowFirstField=!gameField[%%C]!" )
            set /a "rowSecondField=%%A*3-1" && for %%C in (!rowSecondField!) do ( set "rowSecondField=!gameField[%%C]!" )
            set /a "rowThirdField=%%A*3" && for %%C in (!rowThirdField!) do ( set "rowThirdField=!gameField[%%C]!" )

            set /a "fieldIsWinningField=0"
            set done=
            for /l %%A in (1,1,3) do if !displayCounter! equ !winningField[%%A]! if not defined done (
                  set /a "fieldIsWinningField=1"
                  set "done=break"
            )

            if !rowFirstField! equ 0 (
                  set "displayRow1=!playerSign_1!"
                  set "displayRow2=!playerSign_2!"
                  set "displayRow3=!playerSign_3!"
            )

            if !rowFirstField! equ 1 (
                  set "displayRow1=!playerSignX1!"
                  set "displayRow2=!playerSignX2!"
                  set "displayRow3=!playerSignX3!"
            )

            if !rowFirstField! equ 2 (
                  set "displayRow1=!playerSignO1!"
                  set "displayRow2=!playerSignO2!"
                  set "displayRow3=!playerSignO3!"
            )
            set /a "displayCounter+=1"
            set /a "fieldIsWinningField=0"
            set done=
            for /l %%A in (1,1,3) do if !displayCounter! equ !winningField[%%A]! if not defined done (
                  set /a "fieldIsWinningField=1"
                  set "done=break"
            )

            if !rowSecondField! equ 0 (
                  set "displayRow1=!displayRow1! | !playerSign_1!"
                  set "displayRow2=!displayRow2! | !playerSign_2!"
                  set "displayRow3=!displayRow3! | !playerSign_3!"
            )

            if !rowSecondField! equ 1 (
                  set "displayRow1=!displayRow1! | !playerSignX1!"
                  set "displayRow2=!displayRow2! | !playerSignX2!"
                  set "displayRow3=!displayRow3! | !playerSignX3!"
            )

            if !rowSecondField! equ 2 (
                  set "displayRow1=!displayRow1! | !playerSignO1!"
                  set "displayRow2=!displayRow2! | !playerSignO2!"
                  set "displayRow3=!displayRow3! | !playerSignO3!"
            )
            set /a "displayCounter+=1"
            set /a "fieldIsWinningField=0"
            set done=
            for /l %%A in (1,1,3) do if !displayCounter! equ !winningField[%%A]! if not defined done (
                  set /a "fieldIsWinningField=1"
                  set "done=break"
            )

            if !rowThirdField! equ 0 (
                  set "displayRow1=!displayRow1! | !playerSign_1!"
                  set "displayRow2=!displayRow2! | !playerSign_2!"
                  set "displayRow3=!displayRow3! | !playerSign_3!"
            )

            if !rowThirdField! equ 1 (
                  set "displayRow1=!displayRow1! | !playerSignX1!"
                  set "displayRow2=!displayRow2! | !playerSignX2!"
                  set "displayRow3=!displayRow3! | !playerSignX3!"
            )

            if !rowThirdField! equ 2 (
                  set "displayRow1=!displayRow1! | !playerSignO1!"
                  set "displayRow2=!displayRow2! | !playerSignO2!"
                  set "displayRow3=!displayRow3! | !playerSignO3!"
            )
            set /a "displayCounter+=1"

            if %%A equ 1 (
                  set "displayRow1=| !displayRow1! |"
                  set "displayRow2=| !displayRow2! |"
                  set "displayRow3=| !displayRow3! |"
            )

            if %%A equ 2 (
                  set "displayRow1=| !displayRow1! |"
                  set "displayRow2=| !displayRow2! |"
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
sleep 300 ms
)

:endGame
sleep 200 ms
cls
if !winningPlayer! equ 0 echo !translation.offline.win.tie6!
if !winningPlayer! equ 1 echo !translation.offline.win.x6!
if !winningPlayer! equ 2 echo !translation.offline.win.o6!
sleep 50 ms
cls
if !winningPlayer! equ 0 echo !translation.offline.win.tie5!
if !winningPlayer! equ 0 echo !translation.offline.win.tie6!
if !winningPlayer! equ 1 echo !translation.offline.win.x5!
if !winningPlayer! equ 1 echo !translation.offline.win.x6!
if !winningPlayer! equ 2 echo !translation.offline.win.o5!
if !winningPlayer! equ 2 echo !translation.offline.win.o6!
sleep 50 ms
cls
if !winningPlayer! equ 0 echo !translation.offline.win.tie4!
if !winningPlayer! equ 0 echo !translation.offline.win.tie5!
if !winningPlayer! equ 0 echo !translation.offline.win.tie6!
if !winningPlayer! equ 1 echo !translation.offline.win.x4!
if !winningPlayer! equ 1 echo !translation.offline.win.x5!
if !winningPlayer! equ 1 echo !translation.offline.win.x6!
if !winningPlayer! equ 2 echo !translation.offline.win.o4!
if !winningPlayer! equ 2 echo !translation.offline.win.o5!
if !winningPlayer! equ 2 echo !translation.offline.win.o6!
sleep 50 ms
cls
if !winningPlayer! equ 0 echo !translation.offline.win.tie3!
if !winningPlayer! equ 0 echo !translation.offline.win.tie4!
if !winningPlayer! equ 0 echo !translation.offline.win.tie5!
if !winningPlayer! equ 0 echo !translation.offline.win.tie6!
if !winningPlayer! equ 1 echo !translation.offline.win.x3!
if !winningPlayer! equ 1 echo !translation.offline.win.x4!
if !winningPlayer! equ 1 echo !translation.offline.win.x5!
if !winningPlayer! equ 1 echo !translation.offline.win.x6!
if !winningPlayer! equ 2 echo !translation.offline.win.o3!
if !winningPlayer! equ 2 echo !translation.offline.win.o4!
if !winningPlayer! equ 2 echo !translation.offline.win.o5!
if !winningPlayer! equ 2 echo !translation.offline.win.o6!
sleep 50 ms
cls
if !winningPlayer! equ 0 echo !translation.offline.win.tie2!
if !winningPlayer! equ 0 echo !translation.offline.win.tie3!
if !winningPlayer! equ 0 echo !translation.offline.win.tie4!
if !winningPlayer! equ 0 echo !translation.offline.win.tie5!
if !winningPlayer! equ 0 echo !translation.offline.win.tie6!
if !winningPlayer! equ 1 echo !translation.offline.win.x2!
if !winningPlayer! equ 1 echo !translation.offline.win.x3!
if !winningPlayer! equ 1 echo !translation.offline.win.x4!
if !winningPlayer! equ 1 echo !translation.offline.win.x5!
if !winningPlayer! equ 1 echo !translation.offline.win.x6!
if !winningPlayer! equ 2 echo !translation.offline.win.o2!
if !winningPlayer! equ 2 echo !translation.offline.win.o3!
if !winningPlayer! equ 2 echo !translation.offline.win.o4!
if !winningPlayer! equ 2 echo !translation.offline.win.o5!
if !winningPlayer! equ 2 echo !translation.offline.win.o6!
sleep 50 ms
cls
if !winningPlayer! equ 0 echo !translation.offline.win.tie1!
if !winningPlayer! equ 0 echo !translation.offline.win.tie2!
if !winningPlayer! equ 0 echo !translation.offline.win.tie3!
if !winningPlayer! equ 0 echo !translation.offline.win.tie4!
if !winningPlayer! equ 0 echo !translation.offline.win.tie5!
if !winningPlayer! equ 0 echo !translation.offline.win.tie6!
if !winningPlayer! equ 1 echo !translation.offline.win.x1!
if !winningPlayer! equ 1 echo !translation.offline.win.x2!
if !winningPlayer! equ 1 echo !translation.offline.win.x3!
if !winningPlayer! equ 1 echo !translation.offline.win.x4!
if !winningPlayer! equ 1 echo !translation.offline.win.x5!
if !winningPlayer! equ 1 echo !translation.offline.win.x6!
if !winningPlayer! equ 2 echo !translation.offline.win.o1!
if !winningPlayer! equ 2 echo !translation.offline.win.o2!
if !winningPlayer! equ 2 echo !translation.offline.win.o3!
if !winningPlayer! equ 2 echo !translation.offline.win.o4!
if !winningPlayer! equ 2 echo !translation.offline.win.o5!
if !winningPlayer! equ 2 echo !translation.offline.win.o6!

for /l %%. in (1,1,2) do echo.
echo %translation.offline.controls%
choice /c:re /n >nul

if !errorlevel! equ 1 goto buildGame
if !errorlevel! equ 2 exit /b

pause >nul