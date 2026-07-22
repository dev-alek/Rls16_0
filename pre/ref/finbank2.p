block-level on error undo, throw.
define input parameter p-recid as recid no-undo.
define input-output parameter p-status_ as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finbank2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finbank2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса БАНКА".
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
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf_fin-bank for ub.fin-bank.
define buffer buf_fin-schet for ub.fin-schet.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-status_ like ub.fin-bank.status_ no-undo .
do
on error undo, return error
:
FIND FIRST bf_fin-bank WHERE
           recid(bf_fin-bank) = p-recid No-ERROR.
if not avail bf_fin-bank then return error.
varold-status_ = bf_fin-bank.status_.
if p-status_ = ?
or p-status_ = "":U
then do:
  CASE varold-status_:
    when 'тек':U then do:
      assign
      p-status_ = 'удал':U.
    end.
    when 'удал':U then do:
      assign
      p-status_ = 'тек':U.
    end.
  END CASE.
end.
for each buf_fin-schet exclusive-lock where
         buf_fin-schet.host-code = bf_fin-bank.host-code
     AND buf_fin-schet.code-bank = bf_fin-bank.code-bank
on error undo, return error
on stop undo, return error:
  if buf_fin-schet.status_ <> 'удал':U
  and bf_fin-bank.status_ = 'тек':U
  then do:
    message
    "У банка имеются счета в статусе" buf_fin-schet.status_ skip
    "Удаление невозможно"
    view-as alert-box error.
    undo, return error .
  end.
end.
_main:
do
on error undo, return error
:
CASE p-status_:
  WHEN 'тек':U then do:
    if 'тек':U = bf_fin-bank.status_  then do:
      message "БАНК уже имеет статус ТЕКУЩИЙ!"
      view-as alert-box ERROR.
      p-status_ = "".
      return error.
    end.
    else do:
      message
      "Восстановить удаленный банк?"
      view-as alert-box question buttons yES-NO  update choice.
      if choice then
      assign
      bf_fin-bank.status_ = 'тек':U .
      end.
  end.
  WHEN 'удал':U then do:
    choice = FALSE .
    message "Удалить банк Вы уверены?" skip
    view-as alert-box WARNING
    buttons OK-Cancel update choice .
    if choice then  do:
      bf_fin-bank.status_ = 'удал':U .
    end.
  end.
END CASE.
release bf_fin-bank no-error .
if error-status:error then do:
  message
  "Ошибка при сохранении записи БАНК" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo _main, return error .
end.
p-status_ = "".
end.
end.
