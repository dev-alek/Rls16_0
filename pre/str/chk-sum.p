block-level on error undo, throw.
def input-output param code as char no-undo.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: chk-sum.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/chk-sum.p $":U .
def var vss-description as character no-undo init "Рассчет контрольной суммы бар-кода".
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
def var i as int no-undo.
def var sum as int no-undo.
assign
  sum = 0
.
do i = 1 to length(code) by 2
:
  if substring(code,length(code) - i + 1,1) < "0"
  or substring(code,length(code) - i + 1,1) > "9"
  then do:
    return error.
  end.
  assign
    sum = sum + int(substr(code,length(code) - i + 1,1))
  .
end.
assign
  sum = sum * 3
.
do i = 2 to length(code) by 2
:
  if substr(code,length(code) - i + 1,1) < "0"
  or substr(code,length(code) - i + 1,1) > "9"
  then do:
    return error.
  end.
  assign
    sum = sum + int(substr(code,length(code) - i + 1,1))
  .
end.
if sum mod 10 = 0 then do:
  assign
    code = code + '0'
  .
end.
else do:
  assign
    code = code + string(10 - sum mod 10)
  .
end.
