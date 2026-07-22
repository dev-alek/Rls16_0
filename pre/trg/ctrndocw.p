block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.c-trn-doc old buffer old-c-doc .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Триггер на запись документа":U .
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
      p-vss-parameters = substitute('&1|&2|&3|&4|5',ub.c-trn-doc.doc-code,ub.c-trn-doc.chip-num,ub.c-trn-doc.ext-doc-type,ub.c-trn-doc.status_,ub.c-trn-doc.flag_)
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
define variable v-host-code like c-trn-doc.host-code no-undo.
MAIN-BLOCK :
do
on error   undo main-block, return error
on end-key undo main-block, return error
on stop    undo main-block, return error
:
  find first ub.clients no-lock where
             ub.clients.obj-type = ub.c-trn-doc.obj-type and
             ub.clients.obj-code = ub.c-trn-doc.obj-code no-error .
  if not available ub.clients then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Неправильная ссылка на объект" skip
            "Документ " ub.c-trn-doc.doc-code skip
            "Не найден объект" ub.c-trn-doc.obj-type ub.c-trn-doc.obj-code skip
    view-as alert-box error .
    undo main-block, return error .
  end.
  run trg/chkchpnm.p ( input ub.c-trn-doc.doc-code
                 , input ub.c-trn-doc.chip-num
                 , input "c-trn-doc":U
                 , input recid( ub.c-trn-doc )
                 ) no-error .
  if error-status :error then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошибка при проверке уникальности кода документа" skip
            "Документ " ub.c-trn-doc.doc-code skip
            error-status :get-message( 1 ) skip
            return-value skip
    view-as alert-box error .
    undo main-block, return error .
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.c-trn-doc.obj-type
  ,input  ub.c-trn-doc.obj-code
  ,output v-host-code
  ) no-error .
  if error-status :error then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошика при определении кода фирмы для объекта" skip
            "Документ " ub.c-trn-doc.doc-code skip
            "obj-type"  ub.c-trn-doc.obj-type skip
            "obj-code"  ub.c-trn-doc.obj-code skip
            error-status :get-message( 1 ) skip
            return-value skip
    view-as alert-box error .
    undo main-block, return error .
  end.
  if ub.c-trn-doc.host-code <> v-host-code then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Неправильно заполнено поле фирма" skip
            "Документ " ub.c-trn-doc.doc-code skip
            "Объект"    ub.c-trn-doc.obj-type ub.c-trn-doc.obj-code skip
            "Фирма"     ub.c-trn-doc.host-code skip
            "Должна быть фирма" v-host-code skip
    view-as alert-box error .
    undo main-block, return error .
  end.
  if g#news <> yes then do:
    if ub.c-trn-doc.corr-user-name = "":U then do:
      assign
        ub.c-trn-doc.corr-user-name = g#userid
      .
    end.
    run str/callnews.p ( input "c-trn-doc"
                   , input ( buffer ub.c-trn-doc :handle )
                   ) no-error .
    if error-status :error then do:
      message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
              "Невозможно маршрутизировать c-trn-doc для отправки в новости" skip
              error-status :get-message( 1 ) skip
              return-value skip
      view-as alert-box error .
      undo, return error .
    end.
  end.
    if g#oxml = true
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'c-trn-doc':U
        , input ( buffer ub.c-trn-doc:handle )
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
