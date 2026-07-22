block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.c-inkas old buffer old-c-inkas .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории продажи".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3',ub.c-inkas.inkas-code,ub.c-inkas.chip-num,ub.c-inkas.status_)
    .
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
define variable v-host-code like c-inkas.host-code no-undo.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):
  find first ub.clients no-lock
    where ub.clients.obj-type = ub.c-inkas.obj-type
      and ub.clients.obj-code = ub.c-inkas.obj-code
    no-error .
  if not available ub.clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на объект" skip
      "Продажа" ub.c-inkas.inkas-code skip
      "Не найден объект" ub.c-inkas.obj-type ub.c-inkas.obj-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.c-inkas.obj-type
  ,input  ub.c-inkas.obj-code
  ,output v-host-code
  ) no-error .
  if error-status :error then do:
    message
     vss-workfile vss-revision vss-description skip
     "Ошика при определении кода фирмы для объекта" skip
     "Продажа" ub.c-inkas.inkas-code skip
     "obj-type" ub.c-inkas.obj-type skip
     "obj-code" ub.c-inkas.obj-code skip
     error-status :get-message(1) skip
     return-value skip
     view-as alert-box error .
    undo main-block, return error .
  end.
  if ub.c-inkas.host-code <> v-host-code then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильно заполнено поле фирма" skip
      "Продажа" ub.c-inkas.inkas-code skip
      "Объект"  ub.c-inkas.obj-type ub.c-inkas.obj-code skip
      "Фирма"   ub.c-inkas.host-code skip
      "Должна быть фирма" v-host-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  if  not g#news
  and ub.c-inkas.corr-user-name = "" then do:
    assign
      ub.c-inkas.corr-user-name = g#userid
    .
  end.
  if not g#news
  and ub.c-inkas.status_ = 'факт':U
  then do:
    run str/callnews.p (
        input 'c-inkas':U
       ,input (buffer ub.c-inkas:handle)
       ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно маршрутизировать c-inkas для отправки в новости" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'c-inkas':U
        , input ( buffer ub.c-inkas:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.
