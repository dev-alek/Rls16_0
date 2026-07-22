block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.price-doc .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление переоценки".
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
      p-vss-parameters = substitute('&1|&2',ub.price-doc.doc-num,ub.price-doc.status_)
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
define buffer buf_c-price-doc  for ub.c-price-doc  .
define buffer buf_c-price-list for ub.c-price-list  .
define buffer buf_c-price-list-attr for ub.c-price-list-attr  .
define buffer buf_c-doc-attr for ub.c-doc-attr .
define variable v-is-erpRN    as logical no-undo .
define variable par-is-erpRN  as character no-undo .
define variable par-type      as character no-undo .
main-block :
do transaction
on error undo main-block, return error
:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-erpRN'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-erpRN
  ,output par-type
  ) no-error .
  v-is-erpRN = lookup(par-is-erpRN, "true,yes":U) > 0.
  if ub.price-doc.status_ = 'акт':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при удалении документа переоценки" skip
      "Нельзя удалять переоценку, находящуюся в статусе" 'акт':U skip
      "Документ переоценки" ub.price-doc.doc-num skip
      "Статус" ub.price-doc.status_ skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  define buffer buf_clients for ub.clients .
  find first buf_clients no-lock
    where buf_clients.obj-type = ub.price-doc.obj-type
      and buf_clients.obj-code = ub.price-doc.obj-code
    no-error .
  if not available buf_clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден объект" skip
      "Переоценка" ub.price-doc.doc-num skip
      "Объект" ub.price-doc.obj-type ub.price-doc.obj-code skip
      view-as alert-box error .
    undo, return error .
  end.
  if g#news
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Удаление переоценки в новостях невозможно" skip
      "Переоцека" ub.price-doc.doc-num skip
      "Объект" ub.price-doc.obj-type ub.price-doc.obj-code skip
      "Статус" ub.price-doc.status_ skip
      view-as alert-box error .
    undo, return error .
  end.
  if buf_clients.db-num <> 0
  and not v-is-erpRN
  and ub.price-doc.status_ <> 'новый':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Удаление переоценки УБД возвможно только в статусе" 'новый':U skip
      "Переоцека" ub.price-doc.doc-num skip
      "Объект" ub.price-doc.obj-type ub.price-doc.obj-code skip
      "Статус" ub.price-doc.status_ skip
      view-as alert-box error .
    undo, return error .
  end.
  if ub.price-doc.status_ = 'разрешен':U then do:
    if ub.price-doc.obj-type = 'маг':U then do:
      message
        vss-workfile vss-revision vss-description skip
        "Для магазина запрещено удаление переоценок в статусе" ub.price-doc.status_ skip
        "Переоцека" ub.price-doc.doc-num skip
        "Объект" ub.price-doc.obj-type ub.price-doc.obj-code skip
        "Статус" ub.price-doc.status_ skip
        view-as alert-box error .
      undo, return error .
    end.
    for each ub.price-list
      where ub.price-list.doc-num = ub.price-doc.doc-num
    on error undo, return error
    break
    by ub.price-list.artic
    by ub.price-list.prod-type
    by ub.price-list.prod-code
    :
      if last-of(ub.price-list.prod-code) then do:
        define variable l-ov-on as logical no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.price-list.obj-type
  ,input  ub.price-list.obj-code
  ,input  ub.price-list.artic
  ,input  ub.price-list.prod-type
  ,input  ub.price-list.prod-code
  ,input  'ov-on=false'
  ,output l-ov-on
  ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания признака товара на объекте" skip
            "Переоценка" ub.price-list.doc-num skip
            "Объект" ub.price-list.obj-type ub.price-list.obj-code skip
            "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
            "action" "ov-on=false" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.
   if ub.price-doc.status_ <> 'новый':U then do:
      create buf_c-price-doc.
      BUFFER-COPY ub.price-doc TO buf_c-price-doc
      assign
        buf_c-price-doc.chip-num           = next-value (s-corr-chip, ub)
        buf_c-price-doc.corr-time          = time
        buf_c-price-doc.corr-user-db-num   = g#db-num
        buf_c-price-doc.corr-man           = g#userid
        buf_c-price-doc.corr-date          = today
        buf_c-price-doc.is-del             = true
      .
   end.
  for each ub.price-list exclusive-lock
    where ub.price-list.doc-num = ub.price-doc.doc-num
  on error undo main-block, return error
  :
    if ub.price-doc.status_ <> 'новый':U then do:
      create buf_c-price-list.
      BUFFER-COPY ub.price-list TO buf_c-price-list
      assign
        buf_c-price-list.chip-num           = buf_c-price-doc.chip-num
        buf_c-price-list.corr-time           = time
        buf_c-price-list.corr-user-db-num    = g#db-num
        buf_c-price-list.corr-user-name     = g#userid
        buf_c-price-list.corr-date          = today
        buf_c-price-list.is-del             = true
      .
     end.
    delete ub.price-list .
  end.
  for each ub.doc-attr where ub.doc-attr.doc-code = ub.price-doc.doc-num
    on error undo main-block, return error
    :
    if ub.price-doc.status_ <> 'новый':U then do:
      create buf_c-doc-attr.
      BUFFER-COPY ub.doc-attr TO buf_c-doc-attr
      assign
        buf_c-doc-attr.chip-num           = buf_c-price-doc.chip-num
        buf_c-doc-attr.corr-time           = time
        buf_c-doc-attr.corr-user-db-num    = g#db-num
        buf_c-doc-attr.corr-user-name     = g#userid
        buf_c-doc-attr.corr-date          = today
      .
    end.
    delete ub.doc-attr.
  end.
  for each ub.price-list-attr where ub.price-list-attr.doc-num = ub.price-doc.doc-num
    on error undo main-block, return error
    :
    if ub.price-doc.status_ <> 'новый':U then do:
      create buf_c-price-list-attr.
      BUFFER-COPY ub.price-list-attr TO buf_c-price-list-attr
      assign
        buf_c-price-list-attr.chip-num           = buf_c-price-doc.chip-num
        buf_c-price-list-attr.corr-time           = time
        buf_c-price-list-attr.corr-user-db-num    = g#db-num
        buf_c-price-list-attr.corr-user-name     = g#userid
        buf_c-price-list-attr.corr-date          = today
        buf_c-price-list-attr.is-del             = true
      .
    end.
    delete ub.price-list-attr.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'delete':U
        , input 'price-doc':U
        , input ( buffer ub.price-doc:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
  if ub.price-doc.PS <> "temp"
  then do :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_price-doc':U
  ,input  buffer ub.price-doc:handle
  ,input ?
  ,input ''
  ,input ''
  ) no-error .
      if error-status:error
      then do:
        define variable v-message as character no-undo .
        v-message = substitute("&1 &2 &3&4Ошибка при вызове процедуры rum-runa.i&4&5&4&5&6"
                                ,vss-workfile
                                ,vss-revision
                                ,vss-description
                                ,chr(10)
                                , error-status:get-message(1)
                                , return-value ).
        if not g#news
        and not g#auto
        and not g#esys
        then do:
          message
          v-message
          view-as alert-box error .
        end.
        undo main-block,  return error v-message.
      end.
  end.
end.
