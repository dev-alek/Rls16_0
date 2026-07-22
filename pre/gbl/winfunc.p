block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: winfunc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/winfunc.p $":U .
define variable vss-description as character no-undo init "Функции windows".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   DEFINE NEW GLOBAL SHARED VARIABLE hpApi AS HANDLE NO-UNDO.
   IF NOT VALID-HANDLE(hpApi) THEN run gbl/windows.p PERSISTENT SET hpApi.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW GLOBAL SHARED VARIABLE hpWinFunc AS HANDLE NO-UNDO.
  hpWinFunc = this-procedure:handle.
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
FUNCTION CreateProcess RETURNS INTEGER
         (input CommandLine as CHAR,
          input CurrentDir  as CHAR,
          input wShowWindow as INTEGER) :
   define variable lpStartupInfo as memptr.
   set-size(lpStartupInfo)     = 68.
   put-long(lpStartupInfo,1)   = 68.
   put-long (lpStartupInfo,45) = 1.
   put-short(lpStartupInfo,49) = wShowWindow.
   define variable lpProcessInformation as memptr.
   set-size(lpProcessInformation)   = 16.
   define variable lpCurrentDirectory as memptr.
   if CurrentDir<>"" then do:
      set-size(lpCurrentDirectory)     = 256.
      put-string(lpCurrentDirectory,1) = CurrentDir.
   end.
   define variable bResult as integer.
   run CreateProcessA in hpApi
     ( 0,
       CommandLine,
       0,
       0,
       0,
       0,
       0,
       if CurrentDir=""
          then 0
          else get-pointer-value(lpCurrentDirectory),
       get-pointer-value(lpStartupInfo),
       get-pointer-value(lpProcessInformation),
       output bResult
     ).
  define variable hProcess as integer no-undo.
  define variable hThread  as integer no-undo.
  hProcess = get-long(lpProcessInformation,1).
  hThread  = get-long(lpProcessInformation,5).
  define variable ReturnValue as INTEGER NO-UNDO.
  RUN CloseHandle in hpApi(hThread, output ReturnValue).
  set-size(lpStartupInfo)        = 0.
  set-size(lpProcessInformation) = 0.
  set-size(lpCurrentDirectory)   = 0.
  return ( hProcess ).
END FUNCTION.
FUNCTION GetLastError RETURNS INTEGER :
  define variable dwMessageID as integer no-undo.
  run GetLastError in hpApi (output dwMessageID).
  RETURN (dwMessageID).
END FUNCTION.
FUNCTION GetParent RETURNS INTEGER
         (input hWnd as INTEGER) :
  define variable hParent as integer no-undo.
  run GetParent in hpApi (hWnd, output hParent).
  RETURN (hParent).
END FUNCTION.
FUNCTION ShowLastError RETURNS INTEGER :
  define variable ErrorId as integer no-undo.
  define variable txt as char no-undo.
  define variable TxtLength as integer no-undo.
  ErrorId = GetLastError().
  txt = fill(" ",300).
  run FormatMessageA in hpApi (512 + 4096,
                        0,
                        ErrorId,
                        0,
                        output txt,
                        length(txt),
                        0,
                        output TxtLength).
   message  txt view-as alert-box error.
   RETURN ( ErrorId ).
END FUNCTION.
