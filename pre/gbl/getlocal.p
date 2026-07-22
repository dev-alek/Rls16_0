block-level on error undo, throw.
define output parameter par-dec as character no-undo .
define output parameter par-tho as character no-undo .
define output parameter par-sdate as character no-undo .
define output parameter par-shortdate as character no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: getlocal.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/getlocal.p $":U .
def var vss-description as character no-undo init "Определение локальных настроек системы пользователя".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   DEFINE NEW GLOBAL SHARED VARIABLE hpApi AS HANDLE NO-UNDO.
   IF NOT VALID-HANDLE(hpApi) THEN run gbl/windows.p PERSISTENT SET hpApi.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
PROCEDURE GetDateFormatA EXTERNAL "KERNEL32" :
   DEFINE INPUT PARAMETER        Locale      AS LONG.
   DEFINE INPUT PARAMETER        dwFlags     AS LONG.
   DEFINE INPUT PARAMETER        lpTime      AS LONG.
   DEFINE INPUT PARAMETER        lpFormat    AS LONG.
   DEFINE INPUT-OUTPUT PARAMETER lpDateStr   AS CHAR.
   DEFINE INPUT PARAMETER        cchDate     AS LONG.
   DEFINE RETURN PARAMETER       cchReturned AS LONG.
END PROCEDURE.
PROCEDURE GetTimeFormatA EXTERNAL "KERNEL32" :
   DEFINE INPUT PARAMETER        Locale    AS LONG.
   DEFINE INPUT PARAMETER        dwFlags   AS LONG.
   DEFINE INPUT PARAMETER        lpTime    AS LONG.
   DEFINE INPUT PARAMETER        lpFormat  AS LONG.
   DEFINE INPUT-OUTPUT PARAMETER lpTimeStr AS CHAR.
   DEFINE INPUT PARAMETER        cchTime   AS LONG.
   DEFINE RETURN PARAMETER       cchReturned AS LONG.
END PROCEDURE.
DEFINE VARIABLE cchRet as integer no-undo.
do
on error undo, return error
:
assign
par-dec = fill(chr(32),50)
par-tho = fill(chr(32),50)
par-sdate = fill(chr(32),50)
par-shortdate = fill(chr(32),50)
.
  RUN GetLocaleInfoA in hpApi ( 1024
                               ,14
                               ,input-output par-dec
                               ,length(par-dec)
                               ,output cchRet
                                  ).
  RUN GetLocaleInfoA in hpApi ( 1024
                               ,15
                               ,input-output par-tho
                               ,length(par-tho)
                               ,output cchRet
                                  ).
  RUN GetLocaleInfoA in hpApi ( 1024
                               ,31
                               ,input-output par-shortdate
                               ,length(par-shortdate)
                               ,output cchRet
                                  ).
  RUN GetLocaleInfoA in hpApi ( 1024
                               ,29
                               ,input-output par-sdate
                               ,length(par-sdate)
                               ,output cchRet
                                  ).
  assign
  par-dec = trim(par-dec)
  par-tho = trim(par-tho)
  par-sdate = trim(par-sdate)
  par-shortdate = trim(par-shortdate)
  .
end.
