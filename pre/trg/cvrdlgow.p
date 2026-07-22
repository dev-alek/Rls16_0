block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.c-varianty-delivery-gds-obj.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице ИСТОРИЯ ВАРИАНТОВ ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕКТЕ".
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7'
                                       , ub.c-varianty-delivery-gds-obj.gds-code
                                       , ub.c-varianty-delivery-gds-obj.obj-type
                                       , ub.c-varianty-delivery-gds-obj.obj-code
                                       , ub.c-varianty-delivery-gds-obj.deliv-type-code
                                       , ub.c-varianty-delivery-gds-obj.deliv-subj-code
                                       , ub.c-varianty-delivery-gds-obj.corr-user-db-num
                                       , ub.c-varianty-delivery-gds-obj.chip-num
                                        )
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
define variable v-db-num like ub.db.db-num no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_varianty-delivery-gds-obj for ub.varianty-delivery-gds-obj.
define buffer buf_group-period-validity  for ub.group-period-validity.
define buffer buf_var-deliv-gr-per-val for ub.var-deliv-gr-per-val.
define buffer buf_deliv-type-cond-keep for ub.deliv-type-cond-keep.
define buffer buf_goods for ub.goods.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news then do:
    find first buf_goods no-lock where
               buf_goods.gds-code = ub.c-varianty-delivery-gds-obj.gds-code  no-error .
    if not available buf_goods then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ТОВАР" skip
      "код товара" ub.c-varianty-delivery-gds-obj.gds-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_clients no-lock where
               buf_clients.obj-type = c-varianty-delivery-gds-obj.obj-type
           AND buf_clients.obj-code = c-varianty-delivery-gds-obj.obj-code
               no-error .
    if not available buf_clients then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ОБЪЕКТ ДОСТАВКИ" skip
      "тип" c-varianty-delivery-gds-obj.obj-type    skip
      "код" c-varianty-delivery-gds-obj.obj-code   skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_deliv-type-cond-keep no-lock where
               buf_deliv-type-cond-keep.deliv-type-code = ub.c-varianty-delivery-gds-obj.deliv-type-code
           AND buf_deliv-type-cond-keep.cond-keep-code  = ub.c-varianty-delivery-gds-obj.cond-keep-code
               no-error .
    if not available buf_deliv-type-cond-keep then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ТИП ДОСТАВКИ ПО УСЛОВИЯ ХРАНЕНИЯ" skip
      "код типа доставки" ub.c-varianty-delivery-gds-obj.deliv-type-code skip
      "код условий хранения" ub.c-varianty-delivery-gds-obj.cond-keep-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_var-deliv-gr-per-val no-lock where
               buf_var-deliv-gr-per-val.deliv-type-code = ub.c-varianty-delivery-gds-obj.deliv-type-code
           AND buf_var-deliv-gr-per-val.deliv-subj-code = ub.c-varianty-delivery-gds-obj.deliv-subj-code
           AND buf_var-deliv-gr-per-val.obj-type        = ub.c-varianty-delivery-gds-obj.obj-type
           AND buf_var-deliv-gr-per-val.obj-code        = ub.c-varianty-delivery-gds-obj.obj-code
           AND buf_var-deliv-gr-per-val.gr-per-val-code = ub.c-varianty-delivery-gds-obj.gr-per-val-code
               no-error .
    if not available buf_var-deliv-gr-per-val then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ВАРИАНТ ДОСТАВКИ ПО ГРУППЕ СРОКОВ ГОДНОСТИ" skip
      "код типа доставки" ub.c-varianty-delivery-gds-obj.deliv-type-code skip
      "код субъекта доставки" ub.c-varianty-delivery-gds-obj.deliv-subj-code skip
      "тип объекта доставки" ub.c-varianty-delivery-gds-obj.obj-type    skip
      "код объекта доставки" ub.c-varianty-delivery-gds-obj.obj-code   skip
      "код группы сроков годности" ub.c-varianty-delivery-gds-obj.gr-per-val-code   skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_varianty-delivery-gds-obj no-lock where
               buf_varianty-delivery-gds-obj.gds-code        = c-varianty-delivery-gds-obj.gds-code
           AND buf_varianty-delivery-gds-obj.obj-type        = c-varianty-delivery-gds-obj.obj-type
           AND buf_varianty-delivery-gds-obj.obj-code        = c-varianty-delivery-gds-obj.obj-code
           AND buf_varianty-delivery-gds-obj.deliv-type-code = c-varianty-delivery-gds-obj.deliv-type-code
           AND buf_varianty-delivery-gds-obj.deliv-subj-code = c-varianty-delivery-gds-obj.deliv-subj-code
               no-error .
    if not available buf_varianty-delivery-gds-obj then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ВАРИАНТ ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕКТЕ" skip
      "код товара" c-varianty-delivery-gds-obj.gds-code skip
      "код типа доставки" c-varianty-delivery-gds-obj.deliv-type-code skip
      "код субъекта доставки" c-varianty-delivery-gds-obj.deliv-subj-code skip
      "тип объекта доставки" c-varianty-delivery-gds-obj.obj-type    skip
      "код объекта доставки" c-varianty-delivery-gds-obj.obj-code   skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  ub.c-varianty-delivery-gds-obj.obj-type
  ,input  ub.c-varianty-delivery-gds-obj.obj-code
  ,output v-db-num
  )  .
    if g#db-num <> v-db-num then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории ВАРИАНТА ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕТКЕ для объекта другой БД" skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
if
  not g#news
  OR (g#news
      and not ( g#db-num > 0 )
      and ub.c-varianty-delivery-gds-obj.corr-user-name <> (chr(4) +  'СПН':U)
      )
  or (g#news
      and ( g#db-num > 0 )
      and ub.c-varianty-delivery-gds-obj.corr-user-name = (chr(4) +  'СПН':U)
      )
  then
  run str/callnews.p
    (input "c-varianty-delivery-gds-obj"
    ,input (buffer ub.c-varianty-delivery-gds-obj:handle)
    ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'c-varianty-delivery-gds-obj':U
        , input ( buffer ub.c-varianty-delivery-gds-obj:handle )
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
