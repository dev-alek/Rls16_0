block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.trn-doc .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Триггер на удаление документа".
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
      p-vss-parameters = substitute('&1|&2', ub.trn-doc.doc-code, ub.trn-doc.status_)
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
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable v-message as character no-undo .
define buffer bufz_trn-doc for ub.trn-doc.
main-block :
do transaction
on error  undo main-block, return error substitute("&1. error main-block. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on endkey undo main-block, return error substitute("&1. endkey main-block")
on stop   undo main-block, return error substitute("&1. stop main-block")
:
  for each bufz_trn-doc exclusive-lock where
           bufz_trn-doc.doc-code = ub.trn-doc.out-code and
           bufz_trn-doc.status_  = 'готов':U            :
      assign
        bufz_trn-doc.status_ = 'отказ':U
      .
  end.
  if ub.trn-doc.status_ =  'факт':U and
     ub.trn-doc.is-del  <> yes     then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Нельзя удалять документ, закрытый до статуса" 'факт':U skip
            "Документ" ub.trn-doc.doc-code skip
            "Статус документа" ub.trn-doc.status_ skip
    view-as alert-box error .
    undo main-block, return error "Нельзя удалять документ, закрытый до статуса" + 'факт':U.
  end.
  for each ub.doc-line where
           ub.doc-line.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
  :
    delete ub.doc-line .
  end.
  for each ub.inv-line where
           ub.inv-line.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
  :
    message
      vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
      "Найдены записи о нарастающем итоге без основной записи о товаре." skip
      "Документ" ub.trn-doc.doc-code skip
      substitute( "Товар &1 &2 &3", ub.inv-line.artic, ub.inv-line.prod-type, ub.inv-line.prod-code ) skip
      "Удаление невозможно." skip
      view-as alert-box error buttons ok .
    undo main-block, return error "Найдены записи о распределении товара по местам хранени . Удаление невозможно.".
  end.
  for each ub.doc-pl
    where ub.doc-pl.out-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
  :
    message
      vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
      "Найдены записи о распределении товара по местам хранения без основной записи о товаре.." skip
      "Документ" ub.trn-doc.doc-code skip
      "Код товара" ub.doc-pl.gds-code skip
      "Удаление невозможно." skip
      view-as alert-box error buttons ok .
    undo main-block, return error "Найдены записи о распределении товара по местам хранени . Удаление невозможно.".
  end.
  for each ub.parts no-lock where
           ub.parts.out-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
  :
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Найдены не снятые резервы по документу." skip
            "Документ" ub.trn-doc.doc-code skip
            "Артикул" ub.parts.artic ub.parts.prod-type ub.parts.prod-code skip
            "Удаление невозможно." skip
    view-as alert-box error buttons ok .
    undo main-block, return error "Найдены не снятые резервы по документу. Удаление невозможно.".
  end.
  for each ub.parts-root no-lock where
           ub.parts-root.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
  :
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Найдены не снятые резервы по документу." skip
            "Документ" ub.trn-doc.doc-code skip
            "Код товара" ub.parts-root.gds-code skip
            "Удаление невозможно." skip
    view-as alert-box error buttons ok .
    undo main-block, return error "Найдены не снятые резервы по документу. Удаление невозможно.".
  end.
  for each ub.parts-attr no-lock where
           ub.parts-attr.in-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
  :
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Найдены атрибуты партии." skip
            "Документ" ub.trn-doc.doc-code skip
            "Код товара" ub.parts-attr.gds-code skip
            "Код партии" ub.parts-attr.part-code skip
            "Удаление невозможно." skip
    view-as alert-box error buttons ok .
    undo main-block, return error "Найдены атрибуты партии. Удаление невозможно.".
  end.
  for each ub.inv-doc exclusive-lock where
           ub.inv-doc.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
  :
    delete ub.inv-doc.
  end.
  for each ub.marking-attr exclusive-lock where (ub.marking-attr.attr-code = "inv-doc" or ub.marking-attr.attr-code = "inv-doc-scan") and ub.marking-attr.attr-value = ub.trn-doc.doc-code:
    delete ub.marking-attr.
  end.
  if ub.trn-doc.ext-doc-type = 'vt':U
  then do:
    find first ub.utd exclusive-lock where ub.utd.doc-code = ub.trn-doc.doc-code no-error.
    if available (ub.utd)
      then delete ub.utd.
  end.
  else do:
    find first ub.utd exclusive-lock where ub.utd.doc-code = ub.trn-doc.doc-code no-error.
    if available (ub.utd)
    then do:
      for each ub.utd-marking-lines where ub.utd-marking-lines.doc-id =  ub.utd.doc-id and ub.utd-marking-lines.db-num = ub.utd.db-num:
        find first ub.marking where ub.marking.mark = ub.utd-marking-lines.mark no-error.
        if not available (ub.marking) or not ub.marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
          then next.
        ub.marking.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.
      end.
    end.
  end.
  for each ub.trn-doc-sum exclusive-lock where
           ub.trn-doc-sum.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
  :
    delete ub.trn-doc-sum.
  end.
  for each ub.rvs-doc exclusive-lock where
           ub.rvs-doc.out-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
  :
    delete ub.rvs-doc .
  end.
  for each ub.doc-attr exclusive-lock where
           ub.doc-attr.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
  :
    delete ub.doc-attr.
  end.
  if ub.trn-doc.doc-type = 'инв':U then
  do:
    for first ub.inv-doc-attr where
              ub.inv-doc-attr.doc-code = ub.trn-doc.out-code
          and ub.inv-doc-attr.attr-code = "create_date"
    on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
    :
      delete ub.inv-doc-attr.
    end.
    for first ub.inv-doc-attr where
              ub.inv-doc-attr.doc-code = ub.trn-doc.out-code
          and ub.inv-doc-attr.attr-code = "create_time"
    on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
    :
      delete ub.inv-doc-attr.
    end.
  end.
  for each ub.fin-ob where ub.fin-ob.host-code    = ub.trn-doc.host-code and
                           ub.fin-ob.trn-doc-code = ub.trn-doc.doc-code  exclusive-lock
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
  :
    assign
      ub.fin-ob.is-doc-del = yes.
  end.
  for each ub.fin-ob-trn where ub.fin-ob-trn.trn-doc-code = ub.trn-doc.doc-code  and
                               ub.fin-ob-trn.host-code    = ub.trn-doc.host-code exclusive-lock
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
  :
    find first ub.fin-ob where ub.fin-ob.host-code = ub.fin-ob-trn.host-code and
                               ub.fin-ob.doc-code  = ub.fin-ob-trn.doc-code  exclusive-lock no-error.
    if available ub.fin-ob then do:
      assign
        ub.fin-ob.is-doc-del = yes.
    end.
    assign
      ub.fin-ob-trn.is-doc-del = yes.
  end.
  for each ub.fin-gds-part where ub.fin-gds-part.obj-type = ub.trn-doc.obj-type and
                                 ub.fin-gds-part.obj-code = ub.trn-doc.obj-code and
                                 ub.fin-gds-part.out-code = ub.trn-doc.doc-code exclusive-lock
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
  :
    find first ub.fin-ob where ub.fin-ob.host-code = ub.fin-gds-part.host-code   and
                               ub.fin-ob.doc-code  = ub.fin-gds-part.fin-ob-code exclusive-lock no-error.
    if available ub.fin-ob then do:
      assign
        ub.fin-ob.is-doc-del = yes.
    end.
    assign
      ub.fin-gds-part.is-doc-del = yes.
  end.
  for each ub.fin-ob-before where ub.fin-ob-before.host-code         = ub.trn-doc.host-code and
                                  ub.fin-ob-before.trn-doc-code-orig = ub.trn-doc.doc-code  exclusive-lock
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, chr(10), return-value )
  :
    find first ub.fin-ob where ub.fin-ob.host-code = ub.fin-ob-before.host-code and
                               ub.fin-ob.doc-code  = ub.fin-ob-before.doc-code  exclusive-lock no-error.
    if available ub.fin-ob then do:
      assign
        ub.fin-ob.is-doc-del = yes.
    end.
    assign
      ub.fin-ob-before.is-doc-del = yes.
  end.
  if g#db-num <> 0
     or ( ub.trn-doc.status_ = 'запрос':U
          and ub.trn-doc.ext-doc-type = 'iv':U
        )
  then do:
    run nws/cmd-del.p
      ( input "trn-doc":U
      , input ( buffer ub.trn-doc :handle )
      , input "":U
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input 'delete':U
        , input 'trn-doc':U
        , input ( buffer ub.trn-doc:handle )
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
end.
