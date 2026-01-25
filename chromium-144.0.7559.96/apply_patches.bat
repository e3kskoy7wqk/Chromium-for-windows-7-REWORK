@echo off
setlocal EnableDelayedExpansion

REM Set the path to the repository
set "REPO_PATH=E:\a\chromium\src"

REM Temporary file for storing commit hashes
set "temp_file=temp.txt"

REM Count the number of lines in commit_hashes.txt
for /f %%a in ('type "commit_hashes.txt" ^| find /c /v ""') do set "line_count=%%a"

:loop
    REM Decrement line_count
    set /a line_count-=1
    if !line_count! equ 0 (
        REM Process the last line
        for /f "delims=" %%i in (commit_hashes.txt) do (
            echo %%i >> "%temp_file%"
            goto doit
        )
    ) else (
        REM Process other lines
        for /f "skip=%line_count% delims=" %%i in (commit_hashes.txt) do (
            echo %%i >> "%temp_file%"
            goto breakok
        )
    )
:breakok
goto loop

:doit

REM Apply patches and commit changes for each commit
for /f %%a in (%temp_file%) do (
    REM Check and apply patch, ignoring whitespace changes
    git -C "!REPO_PATH!" apply --check --verbose --ignore-space-change "%~dp0%%a.diff"
    if errorlevel 1 (
        echo Failed to apply patch for commit: %%a
        goto end
    ) else (
        git -C "!REPO_PATH!" apply --ignore-space-change "%~dp0%%a.diff"
        if errorlevel 1 (
            echo Failed to apply patch for commit: %%a
            goto end
        )
    )
)

echo All patches applied and committed successfully.

:end
REM Clean up temporary file
del %temp_file%
endlocal
pause
