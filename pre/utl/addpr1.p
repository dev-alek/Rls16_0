block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: addpr1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/addpr1.p $":U .
define variable vss-description as character no-undo init "Пересчет документов по продажным ценам по партиям".
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
define variable p-gds-code as character no-undo .
define variable p-doc-code as character no-undo .
define variable v-vat-pc as decimal   no-undo .
  run gbl/d-prompt.w
    ( 'title=Введите Основной код товара\'
    + 'format=>>>>>>>>>>9\'
    + 'type=integer\'
    ,input-output p-gds-code
    ).
  if return-value = 'false':u
  then do:
    return .
  end.
  run gbl/d-prompt.w
    ( 'title=Введите Номер переоценки обрезания\'
    + 'format=x(20)\'
    + 'type=char\'
    ,input-output p-doc-code
    ).
  if return-value = 'false':u
  then do:
    return .
  end.
find first ub.goods no-lock where
           ub.goods.gds-code = integer(p-gds-code) no-error .
if error-status :error then do:
  message 'Не верно ввведен код, товар не найден' view-as alert-box information .
  return .
end.
find first ub.price-doc no-lock where
           ub.price-doc.doc-num = p-doc-code no-error .
if error-status :error then do:
  message 'Не верно ввведен номер переоценки' view-as alert-box information .
  return .
end.
find first  ub.gds-obj no-lock where
            ub.gds-obj.gds-code = ub.goods.gds-code  and
            ub.gds-obj.obj-code =  ub.price-doc.obj-code  and
            ub.gds-obj.obj-type =  ub.price-doc.obj-type  no-error .
if not available ub.gds-obj then do:
  message 'Нет товара на объекте' view-as alert-box information .
  return .
end.
find first ub.price-list no-lock where
           ub.price-list.doc-num = ub.price-doc.doc-num and
           ub.price-list.price-type = ""   and
           ub.price-list.b-code  = ub.goods.gds-code    no-error .
if not available ub.price-list then do:
v-vat-pc = 0 .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  ub.price-doc.host-code
  ,input  ub.price-doc.obj-type
  ,input  ub.price-doc.obj-code
  ,output v-vat-pc
  ) no-error .
    create  ub.price-list.
    assign
      ub.price-list.doc-num = ub.price-doc.doc-num
      ub.price-list.price-type = ""
      ub.price-list.artic = ub.goods.artic
      ub.price-list.b-code  = ub.goods.gds-code
      ub.price-list.doc-qnty = 0
      ub.price-list.fact-order = ub.price-doc.fact-order
      ub.price-list.line-num   = 1
      ub.price-list.main-price = yes
      ub.price-list.obj-code   = ub.price-doc.obj-code
      ub.price-list.obj-type   = ub.price-doc.obj-type
      ub.price-list.price-sale = ub.gds-obj.price-sale
      ub.price-list.prod-code   = ub.goods.prod-code
      ub.price-list.prod-type   = ub.goods.prod-type
      ub.price-list.SLT-pc      = 0
      ub.price-list.VAT-pc      = v-vat-pc
    .
end.
  message "Все" view-as alert-box information .
