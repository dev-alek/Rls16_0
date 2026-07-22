block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter fnc as char no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gds-cash.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/gds-cash.p $":U .
define variable vss-description as character no-undo init "Пересылка товаров на кассу".
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
define new shared temp-table scn-list no-undo like ub.goods
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table scn-list-hist no-undo
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def NEW shared temp-table goa-list no-undo like ub.gds-obj-attr
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index gds-code-i is primary gds-code obj-type obj-code attr-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable glog as logical no-undo .
define variable v-necessary as logical no-undo .
define variable choice as integer no-undo .
CASE fnc :
  when "qnty" then do:
    run str/scn-list.w ( input parparentproc
                       , input p-curr-host-code
                       , input p-curr-obj-type
                       , input p-curr-obj-code).
    return.
  end.
  when "cash" or
  when 'InfoKiosk':U or
  when 'pricecheck-Servis+':U
  then do:
   run str/gds-list.w ( input parparentproc
                      , input p-curr-host-code
                      , input p-curr-obj-type
                      , input p-curr-obj-code).
  end.
END.
if fnc begins "cash"
or fnc = 'InfoKiosk':U
or fnc = 'pricecheck-Servis+':U
then do:
  if fnc begins "cash"
  then do:
    if not  can-find(first gds-list no-lock) then do:
          message "Вы не определили список товаров для пересылки!"
          view-as alert-box WARNING.
          return.
    end.
    glog = yes.
    message
    "Передать все товары списка на кассы ?"
    view-as alert-box question buttons OK-Cancel update glog.
    if glog <> true then return.
  end.
  if fnc begins 'InfoKiosk':U then do:
    if not  can-find(first gds-list no-lock) then do:
      message
      "Вы не определили список товаров для пересылки" skip
      "Хотите передать справочники групп товаров и справочники шкал?"
      view-as alert-box QUESTION buttons yes-no update glog.
      if not glog then return.
    end.
    run gbl/d-askw.w (input "Опции передачи справочников групп товаров и справочников шкал",
                input  "Выберите необходимую опцию передачи справочников",
                input "|",
                input "Обязательно|По необходим.|Отказ",
                input "БЕЗУСЛОВНАЯ передача справочников|ЕСЛИ после последней передачи справочники МЕНЯЛИСЬ|Отменить",
                input 1,
                input 3,
                output choice).
    if choice = 3
    then do:
        return.
    end.
    if choice = 1 then do:
      v-necessary = yes.
    end.
  end.
  if fnc begins 'pricecheck-Servis+':U then do:
      if not  can-find(first gds-list no-lock) then do:
        message
        "Вы не определили список товаров для пересылки" skip
        view-as alert-box error .
        return.
      end.
      v-necessary = yes.
  end.
end.
CASE fnc:
  when "cash"
  or
  when 'InfoKiosk':U
  then do:
    if fnc = 'InfoKiosk':U then do:
      run str/diallog.w ( input parparentproc
                  , input this-procedure
                  , input 'str/s-infk-1.p':U
                  , input (string( - p-curr-obj-code) + chr(4) +  string(v-necessary))
                  , input can-find(first gds-list no-lock)
                  , input 'Прервать'
                  , input 'Отсылка справочников в ИНФОРМАЦИОННЫЙ КИОСК') no-error .
    end.
    if can-find(first gds-list no-lock) then do:
    run str/diallog.w ( input parparentproc
                  , input this-procedure
                  , input 'str/send-gds.p':U
                  , input (string( - p-curr-obj-code) + chr(4) + "no":U +
                     (if fnc = 'InfoKiosk':U then ( chr(4) + 'InfoKiosk':U + '-only':U)
                      else '')
                    )
                  , input no
                  , input 'Прервать'
                  , input 'Отсылка товаров на кассу') no-error .
    end.
  end.
  when  'pricecheck-Servis+':U
  then do:
       if can-find(first gds-list no-lock) then do:
          run str/diallog.w (
                input parparentproc
              , input this-procedure
              , input 'str/send-gds.p':U
              , input (string( - p-curr-obj-code) + chr(4) +  "no":U +
                  (chr(4) + 'pricecheck-Servis+':U)
                )
              , input no
              , input 'Прервать'
              , input 'Отсылка товаров на ПРАЙС-ЧЕКЕР Сервис+') no-error .
       end.
  end.
END CASE.
