block-level on error undo, throw.
define output parameter p-dir-name  as character no-undo .
define output parameter p-dir-type  as character no-undo .
define output parameter p-can-write as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dir-sel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/dir-sel.p $":U .
define variable vss-description as character no-undo init "Выбор каталога.".
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
on error undo, return error
:
    define variable v-memptr        as memptr       no-undo.
    define variable v-dir-name      as character    no-undo.
    define variable v-success-ind   as integer      no-undo.
    define variable v-success-ind2  as integer      no-undo.
    set-size( v-memptr )    = 1000.
    assign
        v-dir-name              = FILL (" ",255)
    .
    select-directory:
    do while true
    :
        run SHBrowseForFolder in hpApi  (
              input v-memptr
            , output v-success-ind
        ).
        if v-success-ind = 0
        then do:
            leave select-directory.
        end.
        run SHGetPathFromIDList in hpApi (
              input v-success-ind
            , INPUT-OUTPUT v-dir-name
            , OUTPUT v-success-ind2
        ).
        assign
            file-info :file-name = v-dir-name
        .
        assign
            p-dir-name = file-info :file-name
            p-dir-type = file-info :file-type
            p-can-write = ( index( p-dir-type, "W" ) > 0 )
        .
        if index( p-dir-type, "D" ) = 0
        then do:
            message
                "Выбранный каталог недоступен."
                skip "Каталог:" v-dir-name
                skip "Выберите другой каталог"
            view-as alert-box error .
        end.
        else do:
            leave select-directory.
        end.
    end.
    set-size( v-memptr ) = 0.
end.
