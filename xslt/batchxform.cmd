rem Asumes inputDir\ip as source of files, inputDir\op as output directory, and inputDir\test.xls as xls
rem Call as batchxform.cmd c:\Projects\Carsharing\nextbike-swarad

@echo off
    setlocal enableextensions

    cls

    if "%~1"=="" goto endProcess

    set _inputDir=%~1
    set _outputDir=%~1\transform
    set _xsl=C:\Users\Taras.Motulski\YandexDisk\Projects\Carsharing\nextbike_toflat.xsl

    java -jar c:/temp/saxon9/saxon9he.jar -s:"%_inputDir%" -o:"%_outputDir%" -xsl:"%_xsl%"

rem    for %%f in ("%_inputDir%\*.xml") do (
        rem "%_raptor%" xslt --input="%%f" --output="%_outputDir%\%%~nxf"  "%_xsl%"
        rem java -jar c:/temp/saxon9/saxon9he.jar -s:"%%f" -xsl:"%_xsl%" -o:"%_outputDir%\%%~nxf"
        
        rem msxsl "%%f" "%_xsl%" -o "%_outputDir%\%%~nxf"
rem    )

:endProcess
    endlocal