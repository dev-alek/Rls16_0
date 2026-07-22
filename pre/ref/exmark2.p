block-level on error undo, throw.
define input parameter p-db-num    as integer no-undo.
define input parameter p-mark-code as integer no-undo.
define input parameter p-new-stts  as integer no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exmark2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/exmark2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса акцизной или специальной марки".
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
define variable v-msg-text as char no-undo.
define buffer buf_ex-mark for ub.ex-mark.
define buffer sch_ex-mark for ub.ex-mark.
main-block :
do
on error undo, return error substitute( "&1 &2", return-value, error-status :get-message( error-status :num-messages ) )
:
  find buf_ex-mark exclusive-lock
    where buf_ex-mark.db-num    = p-db-num
      and buf_ex-mark.mark-code = p-mark-code
    no-error no-wait.
  if not available buf_ex-mark then do:
    if locked (buf_ex-mark) then do:
      assign
        v-msg-text = "Запись редактируется другим пользователем"
      .
    end.
    else do:
      assign
        v-msg-text = "Не найдена запись акцизной или специальной марки~n"
                   + substitute ("db-num = &1 ; mark-code = &2", p-db-num, p-mark-code)
      .
    end.
    return error v-msg-text.
  end.
  if buf_ex-mark.stts = integer('1':U) then do:
    find first sch_ex-mark no-lock
      where sch_ex-mark.mark-name = buf_ex-mark.mark-name
        and sch_ex-mark.stts      = integer('0':U)
      no-error.
    if available sch_ex-mark then do:
      assign
        v-msg-text = "Восстановление записи невозможно, поскольку существует запись~n" +
                     "с тем же кодом марки в статусе 'Текущий'"
      .
      return error v-msg-text.
    end.
  end.
  assign
    buf_ex-mark.stts = p-new-stts
  .
  release buf_ex-mark no-error .
  if error-status:error then do:
    assign
      v-msg-text = "Ошибка при сохранении записи АКЦИЗНОЙ ИЛИ СПЕЦИАЛЬНОЙ МАРКИ~n"
                 + error-status:get-message(1) + "~n"
                 + return-value
    .
    undo main-block, return error v-msg-text.
  end.
end.
return.
