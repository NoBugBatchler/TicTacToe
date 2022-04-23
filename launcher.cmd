@echo off
pushd assets
start "" "game.cmd" %~1
popd
exit /b