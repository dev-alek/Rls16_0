block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: ini-labl.p $":u .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-labl.p $":u .
define variable vss-description as character no-undo init "Инициализация поля label-name" .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable ii as integer no-undo.
define variable kk as integer no-undo.
define variable choice as integer no-undo.
define variable glog as logical no-undo .
def frame b
ii label "Обработано товаров"
with side-labels title "Заполнение поля НАЗВАНИЕ НА ЭТИКЕТКЕ" view-as dialog-box.
run gbl/d-askw.w (input "Выбор товаров для изменения",
                      input "Вы хотите заполнить поле НАЗВАНИЕ НА ЭТИКЕТКЕ ДЛЯ:",
                      input "|",
                      input "Всех товаров|Выборочно|Отказ",
                      input "||",
                      input 1,
                      input 3,
                      output choice).
if choice = 3 then return.
if choice = 2 then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code) .
    glog = yes.
    message "Заполнить поле НАЗВАНИЕ НА ЭТИКЕТКЕ по всем товарам списка ?  Вы уверены ?"
                view-as alert-box question buttons OK-Cancel update glog.
    if glog <> true then return.
    view frame b.
    ii = 0.
    for each gds-list ON STOP UNDO, NEXT
                            ON ERROR UNDO, NEXT:
      ii = ii + 1.
      find ub.goods where ub.goods.artic = gds-list.artic
                            and ub.goods.prod-type = gds-list.prod-type
                            and ub.goods.prod-code = gds-list.prod-code.
      if ub.goods.label-name = "" then ub.goods.label-name = ub.goods.gds-name.
      disp ii with frame b.
      process events.
      kk = kk + 1.
    end.
end.
else do:
    glog = yes.
    message "Заполнить поле НАЗВАНИЕ НА ЭТИКЕТКЕ по ВСЕМ ТОВАРАМ  ?  Вы уверены ?"
                view-as alert-box question buttons OK-Cancel update glog.
    if glog <> true then return.
    view frame b.
    ii = 0.
    for each ub.goods ON STOP UNDO, NEXT
                            ON ERROR UNDO, NEXT:
      ii = ii + 1.
      if ub.goods.label-name = "" then ub.goods.label-name = ub.goods.gds-name.
      disp ii with frame b.
      process events.
      kk = kk + 1.
    end.
end.
if ii = kk then
message "Заполнение поля НАЗВАНИЕ НА ЭТИКЕТКЕ закончено успешно."
view-as alert-box.
else
message "Из " ii " товаров, выбранных для изменения удалось изменить" kk " !" view-as
alert-box WARNING.
