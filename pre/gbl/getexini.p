block-level on error undo, throw.
define output parameter p-exefile as character no-undo .
define output parameter p-inifile as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getexini.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/getexini.p $":U .
define variable vss-description as character no-undo init "Определение имени выполняемого файла и имени *.ini файла сессии".
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
define variable v-cmdln as character no-undo .
do
on error undo, return error return-value
:
  run gbl/getcmdln.p
    (output v-cmdln
    ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не удалось определить командную строку запуска  сессии"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  assign
    v-cmdln = left-trim(v-cmdln, chr(32))
  .
  do while index(v-cmdln, fill(chr(32), 2)) > 0
  :
    assign
      v-cmdln = replace(v-cmdln, fill(chr(32), 2), chr(32))
    .
  end.
  assign
    p-exefile = trim(entry(1, v-cmdln, chr(32)), chr(34))
  .
  define variable v-ind as integer   no-undo .
  do v-ind = 2 to num-entries(v-cmdln, chr(32))
  :
    if entry(v-ind, v-cmdln, chr(32)) = '-ininame':U
    then do:
      if v-ind + 1 <= num-entries(v-cmdln, chr(32)) then do:
        assign
          p-inifile = entry(v-ind + 1, v-cmdln, chr(32))
        .
      end.
    end.
  end.
  if p-inifile = ""
  or p-inifile = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при разборе командной строки запуска системы" skip
      "В командной строке не задан параметр" '-ininame':u skip
      "Обратитесь к администратору" skip
      "Командная строка" skip
      v-cmdln skip
      view-as alert-box error .
    undo, return error .
  end.
end.
