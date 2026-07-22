block-level on error undo, throw.
define input  parameter commandline as character    no-undo.
define input  parameter workingdir  as character    no-undo.
define output parameter pid         as integer no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: run-gpid.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/run-gpid.p $":U .
define variable vss-description as character no-undo init "Запуск приложения_ получение PID ".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   DEFINE NEW GLOBAL SHARED VARIABLE hpApi AS HANDLE NO-UNDO.
   IF NOT VALID-HANDLE(hpApi) THEN run gbl/windows.p PERSISTENT SET hpApi.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW GLOBAL SHARED VARIABLE hpWinFunc AS HANDLE NO-UNDO.
  IF NOT VALID-HANDLE(hpWinFunc) THEN run gbl/winfunc.p PERSISTENT SET hpWinFunc.
FUNCTION GetLastError
         RETURNS INTEGER
         ()
         IN hpWinFunc.
FUNCTION GetParent
         RETURNS INTEGER
         (input hwnd as INTEGER)
         IN hpWinFunc.
FUNCTION ShowLastError
         RETURNS INTEGER
         ()
         IN hpWinFunc.
FUNCTION CreateProcess
         RETURNS INTEGER
         (input CommandLine as CHAR,
          input CurrentDir  as CHAR,
          input wShowWindow as INTEGER)
         in hpWinFunc.
DEFINE VARIABLE wShowWindow AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE bResult     AS INTEGER NO-UNDO.
DEFINE VARIABLE ReturnValue AS INTEGER NO-UNDO.
  DEFINE VARIABLE lpStartupInfo AS MEMPTR.
  SET-SIZE(lpStartupInfo)     = 68.
  PUT-LONG(lpStartupInfo,1)   = 68.
  PUT-LONG (lpStartupInfo,45) = 1.
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
    RUN CloseHandle IN hpApi(GET-LONG(lpProcessInformation,1), OUTPUT ReturnValue).
    RUN CloseHandle IN hpApi(GET-LONG(lpProcessInformation,5), OUTPUT ReturnValue).
END.
SET-SIZE(lpStartupInfo)        = 0.
SET-SIZE(lpProcessInformation) = 0.
SET-SIZE(lpWorkingDirectory)   = 0.
