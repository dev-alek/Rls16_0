block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
def input param action as char no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcp-cash.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rcp-cash.p $":U .
define variable vss-description as character no-undo init "пересылка компонентов составных товаров на кассу".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE cash-rcp no-undo
FIELD rc as recid
FIELD rcp-string AS char
FIELD news-action as logical
index pi IS UNIQUE PRIMARY rc
.
define variable rid-list as  char    no-undo .
define variable ii as integer no-undo.
define variable choice as integer no-undo.
define variable glog as logical no-undo .
FOR EACH gds-list:
    DELETE gds-list.
END.
run gbl/d-askw.w (input "Выбор топливных рецептов",
                      input ("Передать на кассу "),
                      input "|",
                      input "Все топливные рецепты|Выбрать рецепт из справочника|Отказ",
                      input "|",
                      input 1,
                      input 3,
                      output choice).
CASE choice:
    when 1 then do:
    run ref/rcp-all.w (
          input parparentproc
        , input "b-sel"
        , input 'топливо':U
        , input ?
        , input p-obj-type
        , input p-obj-code
        , output rid-list
    ).
    if rid-list = "" then do:
            message "Вы не определили список топливных рецептов для пересылки их составляющих!"
            view-as alert-box WARNING.
            return.
    end.
    do ii = 1 to NUm-entries(rid-list):
        FIND FIRST ub.recipe no-lock where recid(ub.recipe) = integer(entry(ii, rid-list)) No-ERROR.
        if NOT avail ub.recipe then NEXT.
        if ub.recipe.recipe-type <> 'топливо':U then NEXT.
        FIND FIRST ub.goods no-lock where ub.goods.artic = ub.recipe.artic AND
                                                              ub.goods.prod-type = ub.recipe.prod-type AND
                                                              ub.goods.prod-code = ub.recipe.prod-code NO-ERROR.
        FIND FIRST gds-list NO-LOCK where gds-list.artic = ub.goods.artic AND
                                                                    gds-list.prod-type = ub.goods.prod-type AND
                                                                    gds-list.prod-code = ub.goods.prod-code No-ERROR.
        IF not avail gds-list then do:
            create gds-list.
            buffer-copy goods to gds-list.
        end.
    end.
end.
when 2 then do:
   FOR EACH ub.recipe no-lock where ub.recipe.recipe-type =  'топливо':U:
        FIND FIRST ub.goods no-lock where ub.goods.artic = ub.recipe.artic AND
                                                              ub.goods.prod-type = ub.recipe.prod-type AND
                                                              ub.goods.prod-code = ub.recipe.prod-code NO-ERROR.
        FIND FIRST gds-list NO-LOCK where gds-list.artic = goods.artic AND
                                                                    gds-list.prod-type = ub.goods.prod-type AND
                                                                    gds-list.prod-code = ub.goods.prod-code No-ERROR.
        IF not avail gds-list then do:
            create gds-list.
            buffer-copy goods to gds-list.
        end.
    END.
end.
END CASE.
if not  can-find(first gds-list no-lock) then do:
        message "К сожалению список топливных рецептов пуст!"
        view-as alert-box WARNING.
        return.
end.
glog = yes.
message
"Передать все товары списка на кассы ?"
view-as alert-box question buttons OK-Cancel update glog.
if glog <> true then return.
run str/diallog.w (
              input parparentproc
            , input this-procedure
            , input 'str/s-cgds.p':U
            , input (string(p-obj-code) + chr(4) + action)
            , input no
            , input '':U
            , input 'Передача товаров на кассы') no-error .
