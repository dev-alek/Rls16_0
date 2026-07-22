block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: run-gpid.p $
$Archive: gbl/run-gpid.p $

Запуск приложения_ получение PID

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/02/06
Author: Bakhtadze Natalya
Creation date: 05/02/06

*/


define input  parameter commandline as character    no-undo.
define input  parameter workingdir  as character    no-undo.
define output parameter pid         as integer no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: run-gpid.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/run-gpid.p $":U .
define variable vss-description as character no-undo init "Запуск приложения_ получение PID ".
{ cmp/vssrevis.i }
{ gbl/windows.i }



DEFINE VARIABLE wShowWindow AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE bResult     AS INTEGER NO-UNDO.
DEFINE VARIABLE ReturnValue AS INTEGER NO-UNDO.

  DEFINE VARIABLE lpStartupInfo AS MEMPTR.
  SET-SIZE(lpStartupInfo)     = 68.
  PUT-LONG(lpStartupInfo,1)   = 68.
  PUT-LONG (lpStartupInfo,45) = 1. /* = STARTF_USESHOWWINDOW */
  PUT-SHORT(lpStartupInfo,49) = wShowWindow.

  DEFINE VARIABLE lpProcessInformation AS MEMPTR.
  SET-SIZE(lpProcessInformation)   = 16.

  DEFINE VARIABLE lpWorkingDirectory AS MEMPTR.
  IF WorkingDir NE "" THEN DO:
    SET-SIZE(lpWorkingDirectory)     = 256.
    PUT-STRING(lpWorkingDirectory,1) = WorkingDir.
  END.

  RUN CreateProcessA IN hpApi
    ( 0,
      CommandLine,
      0,
      0,
      0,
      0,
      0,
      IF WorkingDir=""
        THEN 0
        ELSE GET-POINTER-VALUE(lpWorkingDirectory),
      GET-POINTER-VALUE(lpStartupInfo),
      GET-POINTER-VALUE(lpProcessInformation),
      OUTPUT bResult
    ).

IF bResult=0 THEN
    PID = 0.
ELSE DO:
    PID      = GET-LONG(lpProcessInformation,9).
    /* release kernel-objects hProcess and hThread: */
    RUN CloseHandle IN hpApi(GET-LONG(lpProcessInformation,1), OUTPUT ReturnValue).
    RUN CloseHandle IN hpApi(GET-LONG(lpProcessInformation,5), OUTPUT ReturnValue).
END.

SET-SIZE(lpStartupInfo)        = 0.
SET-SIZE(lpProcessInformation) = 0.
SET-SIZE(lpWorkingDirectory)   = 0.
