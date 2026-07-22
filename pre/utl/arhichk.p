block-level on error undo, throw.
define input  parameter p-obj-type         as character no-undo .
define input  parameter p-obj-code         as integer   no-undo .
define input  parameter p-archive-type     as character no-undo .
define input  parameter p-action-type      as character no-undo .
define input  parameter p-start-check-date as date      no-undo .
define input  parameter p-error-number     as integer   no-undo .
define input  parameter p-status-message   as character no-undo .
define output parameter p-create-chip-num  as integer   no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: arhichk.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/arhichk.p $":U .
define variable vss-description as character no-undo initial "Создание истории по сохранению архива".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define buffer buf_archive-history for ub.archive-history .
do
on error undo, return error return-value
:
  if p-archive-type = ?
  or lookup(p-archive-type
           , 'arh':U
           + chr(44) + 'ahsp':U
           + chr(44) + 'aht':U
           + chr(44) + 'prc':U
           ) = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение параметра типа архива" skip
      "Объект" p-obj-type p-obj-code skip
      "Тип архива" p-archive-type skip
      "Действие" p-action-type skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if p-action-type = ?
  or lookup(p-action-type
           ,'check-start':U
           + chr(44) + 'check-stop':U
           ) = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение параметра действия" skip
      "Объект" p-obj-type p-obj-code skip
      "Тип архива" p-archive-type skip
      "Действие" p-action-type skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  define variable v-chip-num as integer   no-undo .
  find last buf_archive-history exclusive-lock
    where buf_archive-history.obj-type     = p-obj-type
      and buf_archive-history.obj-code     = p-obj-code
      and buf_archive-history.archive-type = p-archive-type
    use-index pi
    no-error .
  if available buf_archive-history
  then do:
    assign
      v-chip-num = buf_archive-history.chip-num + 1
    .
  end.
  else do:
    assign
      v-chip-num = 1
    .
  end.
  assign
    p-create-chip-num = v-chip-num
  .
  create buf_archive-history .
  assign
    buf_archive-history.obj-type     = p-obj-type
    buf_archive-history.obj-code     = p-obj-code
    buf_archive-history.archive-type = p-archive-type
    buf_archive-history.chip-num     = v-chip-num
    buf_archive-history.action-type  = p-action-type
  .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output buf_archive-history.corr-user-db-num
  ,output buf_archive-history.corr-user-name
  ,output buf_archive-history.corr-date
  ,output buf_archive-history.corr-time-str
  ,output buf_archive-history.corr-time
  )  .
  assign
    buf_archive-history.source-date = p-start-check-date
    buf_archive-history.PS          = p-status-message
  .
end.
