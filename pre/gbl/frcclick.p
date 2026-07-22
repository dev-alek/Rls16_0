block-level on error undo, throw.
define input parameter wh as widget-handle.
define input parameter wh-1 as widget-handle.
define input parameter l-r as logical.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: frcclick.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/frcclick.p $":U .
define variable vss-description as character no-undo init "Имитировать нажатие мыши".
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
do
on error undo, return error return-value
:
  run MouseCursor in this-procedure
    (input wh
    ,input WH-1
    ).
  run Apply-mouse-menu-click in this-procedure
    (input wh
    ).
  return.
end.
PROCEDURE MouseCursor:
   DEFINE INPUT PARAMETER  p-wh   AS WIDGET-HANDLE  NO-UNDO.
   DEFINE INPUT PARAMETER  p-wh-1   AS WIDGET-HANDLE  NO-UNDO.
   define variable lppoint     AS MEMPTR  NO-UNDO.
   define variable ReturnValue AS INTEGER NO-UNDO.
   SET-SIZE(lppoint)= 2 * 4.
 IF P-WH-1 = ? THEN DO:
      PUT-long(lppoint,1 + 0 * 4)=INTEGER(p-wh:WIDTH-PIXELS / 2).
      PUT-long(lppoint,1 + 1 * 4)=INTEGER(p-wh:HEIGHT-PIXELS / 2).
  END.
  ELSE DO:
      PUT-long(lppoint,1 + 0 * 4)=INTEGER(P-WH-1:x + p-wh-1:WIDTH-PIXELS / 2).
      PUT-long(lppoint,1 + 1 * 4)=INTEGER(P-WH-1:y - p-wh-1:HEIGHT-PIXELS / 2).
  END.
   RUN ClientToScreen in hpApi (INPUT p-wh:HWND,
                                INPUT GET-POINTER-VALUE(lppoint),
                                OUTPUT ReturnValue).
   RUN SetCursorPos in hpApi   (INPUT GET-long(lppoint,1 + 0 * 4),
                                INPUT GET-long(lppoint,1 + 1 * 4),
                                OUTPUT ReturnValue).
   SET-SIZE(lppoint)= 0.
   END PROCEDURE.
PROCEDURE Apply-mouse-menu-click:
   DEFINE INPUT PARAMETER  p-wh   AS WIDGET-HANDLE  NO-UNDO.
   define variable ReturnValue AS INTEGER NO-UNDO.
   RUN SendMessageA in hpApi (INPUT p-wh:HWND,
                                 INPUT (if l-r then 516 else 513),
                                 INPUT (if l-r then 2 else 1),
                                 INPUT 0,
                                 OUTPUT ReturnValue).
   RUN SendMessageA in hpApi (INPUT p-wh:HWND,
                                 INPUT (if l-r then 517 else 514),
                                 INPUT 0,
                                 INPUT 0,
                                 OUTPUT ReturnValue).
END PROCEDURE.
