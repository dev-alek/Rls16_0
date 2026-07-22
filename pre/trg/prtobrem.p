block-level on error undo, throw.
define input  parameter p-trn-doc    as logical   no-undo .
define input  parameter p-doc-code   as character no-undo .
define input  parameter p-delete-doc as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Передача информации об остатках в УБД".
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
      p-vss-parameters = substitute('&1|&2|&3':u,p-trn-doc,p-doc-code,p-delete-doc)
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
define buffer buf_trn-doc    for ub.trn-doc .
define buffer buf_price-doc  for ub.price-doc .
define buffer buf_clients    for ub.clients .
define buffer buf_db         for ub.db .
define buffer buf_doc-line   for ub.doc-line .
define buffer buf_prt-obj    for ub.prt-obj .
define buffer buf_price-list for ub.price-list .
define variable v-obj-type  like ub.clients.obj-type no-undo .
define variable v-obj-code  like ub.clients.obj-code no-undo .
do
on error undo, return error return-value
:
  if p-trn-doc = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "p-trn-doc" p-trn-doc skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error .
  end.
  if p-trn-doc = true
  then do:
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден складской документ" skip
        "p-trn-doc" p-trn-doc skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-need-send-prt-obj-not-fact as logical   no-undo .
    define variable v-parameter-value            as character no-undo .
    define variable v-parameter-type             as character no-undo .
    assign
      v-need-send-prt-obj-not-fact = false
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'remorsrv':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  false
  ,output v-parameter-value
  ,output v-parameter-type
  ) no-error .
    if error-status :error
    then do:
    end.
    else do:
      if  v-parameter-value = 'all':u
      and g#db-num = 0
      then do:
        assign
          v-need-send-prt-obj-not-fact = true
        .
      end.
    end.
    if ( v-need-send-prt-obj-not-fact = true
         and p-delete-doc = true
       )
    or ( v-need-send-prt-obj-not-fact = true
         and buf_trn-doc.status_ = 'накл':U
         and buf_trn-doc.flag_ = true
       )
    or ( v-need-send-prt-obj-not-fact = true
         and buf_trn-doc.status_ = 'разрешен':U
         and buf_trn-doc.flag_ = true
       )
    or ( v-need-send-prt-obj-not-fact = true
         and buf_trn-doc.status_ = 'готов':U
       )
    or ( v-need-send-prt-obj-not-fact = true
         and buf_trn-doc.status_ = 'отказ':U
        )
    or (buf_trn-doc.status_ = 'факт':U)
    then do:
    end.
    else do:
      return .
    end.
    assign
      v-obj-type  = buf_trn-doc.obj-type
      v-obj-code  = buf_trn-doc.obj-code
    .
  end.
  if p-trn-doc = false
  then do:
    find first buf_price-doc no-lock
      where buf_price-doc.doc-num = p-doc-code
      no-error .
    if not available buf_price-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена переоценка" skip
        "p-trn-doc" p-trn-doc skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_price-doc.status_ <> 'акт':U
    then do:
      return .
    end.
    assign
      v-obj-type  = buf_price-doc.obj-type
      v-obj-code  = buf_price-doc.obj-code
    .
  end.
  find first buf_clients no-lock
    where buf_clients.obj-type = v-obj-type
      and buf_clients.obj-code = v-obj-code
    .
  if g#db-num = 0
  then do:
    define variable list-remote-db as character no-undo .
    assign
      list-remote-db = ""
    .
    for each buf_db no-lock
      where buf_db.remote-stock = yes
        and buf_db.db-num    <> g#db-num
        and buf_db.db-num    <> buf_clients.db-num
        and buf_db.db-num    <> 0
    on error undo, return error return-value
    :
      assign
        list-remote-db = list-remote-db
                       + (if list-remote-db <> "" then chr(1) else "")
                       + string(buf_db.db-num)
      .
    end.
    if list-remote-db <> ""
    then do:
      if p-trn-doc = true
      then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = p-doc-code
        on error undo, return error
        :
          for each buf_prt-obj no-lock
            where buf_prt-obj.obj-type  = buf_doc-line.obj-type
              and buf_prt-obj.obj-code  = buf_doc-line.obj-code
              and buf_prt-obj.artic     = buf_doc-line.artic
              and buf_prt-obj.prod-type = buf_doc-line.prod-type
              and buf_prt-obj.prod-code = buf_doc-line.prod-code
          on error undo, return error
          :
            run nws/cr-route.p
              (input 'send-tbl':U
              ,input 'prt-obj':U
              ,input (buffer buf_prt-obj:handle)
              ,input list-remote-db
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при отправке остатков по товару в новости" skip
                "Документ" p-doc-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
      end.
      else do:
        for each buf_price-list no-lock
          where buf_price-list.doc-num    = p-doc-code
            and buf_price-list.main-price = true
        on error undo, return error
        :
          for each buf_prt-obj no-lock
            where buf_prt-obj.obj-type  = buf_price-list.obj-type
              and buf_prt-obj.obj-code  = buf_price-list.obj-code
              and buf_prt-obj.artic     = buf_price-list.artic
              and buf_prt-obj.prod-type = buf_price-list.prod-type
              and buf_prt-obj.prod-code = buf_price-list.prod-code
          on error undo, return error
          :
            run nws/cr-route.p
              (input 'send-tbl':U
              ,input 'prt-obj':U
              ,input (buffer buf_prt-obj:handle)
              ,input list-remote-db
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при отправке остатков по товару в новости" skip
                "Документ" p-doc-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
      end.
    end.
  end.
end.
