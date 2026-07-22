block-level on error undo, throw.
define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-shift-date as date no-undo .
define input parameter p-shift-num as integer no-undo .
define input parameter p-shift-name as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shtwaicr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/shtwaicr.p $":U .
define variable vss-description as character no-undo init "Создание ожидаемой смены".
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
define variable v-err-mess as character no-undo .
define variable v-host-code as integer no-undo .
define variable obj-db-num as integer no-undo .
define buffer buf_shift-obj for ub.shift-obj.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.
main-block:
do
on error undo, return error
:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output obj-db-num
  )  .
  if g#db-num <> obj-db-num then do:
    v-err-mess = substitute("Ожидаемую смену можно создать/изменить только в БД объекта").
    run err-mess in this-procedure ( input-output v-err-mess) .
    undo main-block, return error (if p-silent then v-err-mess else '').
  end.
  if p-shift-date = ? then do:
    v-err-mess = substitute("Не задана дата ожидаемой смены").
    run err-mess in this-procedure ( input-output v-err-mess) .
    undo main-block, return error (if p-silent then v-err-mess else '').
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    find first buf_shift-obj no-lock
      where buf_shift-obj.obj-type = p-obj-type
        and buf_shift-obj.obj-code = p-obj-code
        and buf_shift-obj.shift-date = p-shift-date
        and  buf_shift-obj.shift-num = p-shift-num
      no-error .
    if available buf_shift-obj then do:
      v-err-mess = substitute("Уже есть смена за дату: &1&2          порядок: &3"
                          ,string(p-shift-date, "99/99/9999")
                          ,chr(10)
                          ,p-shift-num).
      run err-mess in this-procedure ( input-output v-err-mess) .
      undo, return error (if p-silent then v-err-mess else '').
    end.
    create buf_shift-obj.
    assign
      buf_shift-obj.host-code  = v-host-code
      buf_shift-obj.obj-type   = p-obj-type
      buf_shift-obj.obj-code   = p-obj-code
      buf_shift-obj.shift-date = p-shift-date
      buf_shift-obj.shift-num  = p-shift-num
      buf_shift-obj.shift-name = p-shift-name
      buf_shift-obj.status_    = 'ожд':U
      buf_shift-obj.fact-order = 0
      p-rec = recid(buf_shift-obj)
    .
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_shift-obj exclusive-lock
      where recid(buf_shift-obj) = p-rec
    .
    if buf_shift-obj.obj-type <> p-obj-type
    or buf_shift-obj.obj-code <> p-obj-code
    or buf_shift-obj.shift-date <> p-shift-date
    or buf_shift-obj.shift-num <> p-shift-num
    then do:
       v-err-mess = "Для уже имеющейся смены нельзя менять дату смены и/или порядок смены".
        run err-mess in this-procedure ( input-output v-err-mess) .
        undo, return error (if p-silent then v-err-mess else '').
    end.
    if buf_shift-obj.status_ <> 'ожд':U then do:
       v-err-mess = "Можно изменить только ожидаемую смену".
        run err-mess in this-procedure ( input-output v-err-mess) .
        undo, return error (if p-silent then v-err-mess else '').
    end.
    assign
    buf_shift-obj.shift-name = p-shift-name
    .
  end.
  release buf_shift-obj no-error.
  if error-status:error then do:
    v-err-mess = substitute("Ошибка при сохранении :&1&2&1&3"
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value ).
    run err-mess in this-procedure ( input-output v-err-mess) .
    undo main-block, return error (if p-silent then v-err-mess else '').
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("(Ожидамемая) Смена на объекте: &1&2 от &3 номер &4 порядок &5:&6&7"
                         , p-obj-type
                         , p-obj-code
                         , string(p-shift-date, "99/99/9999")
                         , p-shift-name
                         , p-shift-num
                         , chr(10)
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
