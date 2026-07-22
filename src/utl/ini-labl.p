block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ini-labl.p $
$Archive: utl/ini-labl.p $

Инициализация поля label-name

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: ini-labl.p $":u .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-labl.p $":u .
define variable vss-description as character no-undo init "Инициализация поля label-name" .
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/getcntxt.i def }
{ cmp/gds-list.i gds-list def "new shared" }

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
    { gbl/getcntxt.i get }
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

