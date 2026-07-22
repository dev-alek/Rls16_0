block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gds-cash.p $
$Archive: str/gds-cash.p $

Пересылка товаров на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

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
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/gds-list.i gds-list def "new shared" }
&undefine gds-list_i_def
{ cmp/gds-list.i scn-list def "new shared" }
{ cmp/goa-list.i goa-list def "NEW shared" }
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
  when {&cd-type-infokiosk} or
  when {&cd-type-pricecheck-Servispl}
  then do:
   run str/gds-list.w ( input parparentproc
                      , input p-curr-host-code
                      , input p-curr-obj-type
                      , input p-curr-obj-code).
  end.
END.
if fnc begins "cash"
or fnc = {&cd-type-infokiosk}
or fnc = {&cd-type-pricecheck-Servispl}
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
  if fnc begins {&cd-type-infokiosk} then do:
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
  if fnc begins {&cd-type-pricecheck-Servispl} then do:
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
  when {&cd-type-infokiosk}
  then do:
    if fnc = {&cd-type-infokiosk} then do:
      run str/diallog.w ( input parparentproc
                  , input this-procedure
                  , input 'str/s-infk-1.p':U
                  , input (string( - p-curr-obj-code) + {&delim-par} +  string(v-necessary))
                  , input can-find(first gds-list no-lock) /*p-auto-go*/
                  , input 'Прервать'
                  , input 'Отсылка справочников в ИНФОРМАЦИОННЫЙ КИОСК') no-error .
    end.
    if can-find(first gds-list no-lock) then do:
    run str/diallog.w ( input parparentproc
                  , input this-procedure
                  , input 'str/send-gds.p':U
                  , input (string( - p-curr-obj-code) + {&delim-par} + "no":U +
                     (if fnc = {&cd-type-infokiosk} then ( {&delim-par} + {&cd-type-infokiosk} + '-only':U)
                      else '')
                    )
                  , input no /*p-auto-go*/
                  , input 'Прервать'
                  , input 'Отсылка товаров на кассу') no-error .
    end.
  end.
  when  {&cd-type-pricecheck-Servispl}
  then do:
       if can-find(first gds-list no-lock) then do:
          run str/diallog.w (
                input parparentproc
              , input this-procedure
              , input 'str/send-gds.p':U
              , input (string( - p-curr-obj-code) + {&delim-par} +  "no":U +
                  ({&delim-par} + {&cd-type-pricecheck-Servispl})
                )
              , input no /*p-auto-go*/
              , input 'Прервать'
              , input 'Отсылка товаров на ПРАЙС-ЧЕКЕР Сервис+') no-error .
       end.
  end.
END CASE.