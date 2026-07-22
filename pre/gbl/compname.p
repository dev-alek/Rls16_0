block-level on error undo, throw.
define output parameter p-computer-name as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: compname.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/compname.p $":U .
define variable vss-description as character no-undo init "Получить текущее имя компьютера".
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
define variable v-computer-name-max-size as integer   no-undo .
define variable v-memptr-computer-name   as memptr    no-undo .
define variable v-error-value            as integer   no-undo .
define variable v-result                 as integer   no-undo .
do
on error undo, return error return-value
:
  assign
    v-computer-name-max-size = 1024
  .
  assign
    set-size(v-memptr-computer-name) = v-computer-name-max-size + 5
  .
  assign
    put-long(v-memptr-computer-name, 1) = v-computer-name-max-size
  .
  run GetComputerNameA
    (input  get-pointer-value(v-memptr-computer-name) + 4
    ,input  get-pointer-value(v-memptr-computer-name)
    ,output v-result
    ) .
  if v-result = 0
  then do:
    run GetLastError
      (output v-error-value
      ) .
  end.
  else do:
    assign
      p-computer-name = get-string(v-memptr-computer-name, 5)
    .
  end.
  assign
    set-size(v-memptr-computer-name) = 0
  .
  if v-result = 0
  then do:
    undo, return error
      substitute("Ошибка при определении текущего имени компьютера. Номер ошибки &1"
                ,v-error-value
                ) .
  end.
end.
PROCEDURE GetComputerNameA EXTERNAL "kernel32.dll"
:
   DEFINE INPUT        PARAMETER lpBuffer AS LONG .
   DEFINE INPUT        PARAMETER lpnSize  AS LONG .
   DEFINE RETURN       PARAMETER RetParam  AS LONG .
END PROCEDURE .
PROCEDURE GetLastError EXTERNAL "kernel32.dll"
:
    DEFINE RETURN       PARAMETER RetParam  AS LONG .
END PROCEDURE.
