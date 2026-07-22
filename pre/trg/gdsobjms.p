block-level on error undo, throw.
define input  parameter p-obj-type         like ub.gds-obj.obj-type  no-undo .
define input  parameter p-obj-code         like ub.gds-obj.obj-code  no-undo .
define input  parameter p-artic            like ub.gds-obj.artic     no-undo .
define input  parameter p-prod-type        like ub.gds-obj.prod-type no-undo .
define input  parameter p-prod-code        like ub.gds-obj.prod-code no-undo .
define input  parameter p-action           as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Вывести информацию о товаре на объекте".
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
case p-action :
  when "ov-on" then do:
    define buffer buf_goods      for ub.goods .
    define buffer buf_price-doc  for ub.price-doc .
    define buffer buf_price-list for ub.price-list .
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    for each buf_price-doc no-lock
      where buf_price-doc.obj-type = p-obj-type
        and buf_price-doc.obj-code = p-obj-code
        and buf_price-doc.status_  = 'разрешен':U
    ,first buf_price-list no-lock
      where buf_price-list.doc-num   = buf_price-doc.doc-num
        and buf_price-list.artic     = p-artic
        and buf_price-list.prod-type = p-prod-type
        and buf_price-list.prod-code = p-prod-code
    on error undo, return error
    :
      message
        "Для товара сейчас идет переоценка" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        buf_goods.gds-name skip
        "Переоценка" buf_price-doc.doc-num skip
        "Включить переоценку невозможно."
        view-as alert-box .
      return .
    end.
    message
      vss-workfile vss-revision vss-description skip
      "Установлен признак того, что для товара идет переоценка" skip
      "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
      buf_goods.gds-name skip
      "Переоценка в статусе" 'разрешен':U "не найдена" skip
      view-as alert-box error .
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестное значение параметра p-action " skip
      "p-action" p-action skip
      view-as alert-box error .
    undo, return error .
  end.
end.
