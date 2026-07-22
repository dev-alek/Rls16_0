block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.icnt-doc.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление документа счетчиков ТРК ".
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
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news
  then do:
    if ub.icnt-doc.status_ <> 'новый':U then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка удаления документа счетчиков ТРК" skip
        "Документ может быть удален только в статусе новый" skip
        "Документ " ub.icnt-doc.doc-code skip
        "Статус" ub.icnt-doc.status_ skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.
  if ub.icnt-doc.status_ = 'факт':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка удаления документа счетчиков ТРК" skip
      "Документ не может быть удален в статусе" 'факт':U skip
      "Документ " ub.icnt-doc.doc-code skip
      "Статус" ub.icnt-doc.status_ skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  for each ub.icnt-line exclusive-lock
    where ub.icnt-line.doc-code = ub.icnt-doc.doc-code
  on error undo main-block, return error
  :
    delete ub.icnt-line .
  end.
  for each ub.doc-attr where ub.doc-attr.doc-code = ub.icnt-doc.doc-code
    on error undo main-block, return error
    :
    delete ub.doc-attr.
  end.
  run nws/cmd-del.p
    ( input 'icnt-doc':U
     ,input (buffer ub.icnt-doc:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( error-status :num-messages ) ).
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input 'delete':U
        , input 'icnt-doc':U
        , input ( buffer ub.icnt-doc:handle )
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
  if ub.icnt-doc.status_ = 'факт':U then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_icnt-doc':U
  ,input  buffer ub.icnt-doc:handle
  ,input ''
  ,input ''
  ,input ''
  ) no-error .
    if error-status :error
    then
    do:
        return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
            , chr(10)
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
    end.
  end .
end.
