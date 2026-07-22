block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ushcd1.p $
$Archive: utl/ushcd1.p $

Утилита заполнения полей в таблице shop, относящихся к пересылке товаров на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/09/06
Author: Bakhtadze Natalya
Creation date: 04/09/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ushcd1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ushcd1.p $":U .
define variable vss-description as character no-undo init "Утилита заполнения полей в таблице shop, относящихся к пересылке товаров на кассу".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/waitfram.i }

define variable logs as logical no-undo init no.
message
"ВЫ отредактировали НАЧАЛЬНЫЕ НАСТРОЙКИ ДЛЯ ОБЪЕКТОВ фирмы," skip
"ответственные за пересылку товаров на кассы по ВСЕМ фирмам ?" view-as alert-box QUESTION
buttons YES-NO update logs.
IF NOT logs then return.

run waitfram-show in this-procedure ("Ждите ....").

for each ub.shop break by ub.shop.host-code:
  run waitfram-show in this-procedure ("Магазин N " + string(ub.shop.obj-code) + "...").
    IF FIRST-OF(ub.shop.host-code) then do:
        FIND FIRST ub.sysconf No-LOCK WHERE
                                                      ub.sysconf.host-code = ub.shop.host-code No-ERROR.
    end.
    else release ub.sysconf.
    if avail ub.sysconf then do:
    assign ub.shop.cd-bc-alt = ub.sysconf.cd-bc-alt
                ub.shop.cd-bc-base = ub.sysconf.cd-bc-base
                ub.shop.cd-loc-alt = ub.sysconf.cd-loc-alt
                ub.shop.cd-loc-base = ub.sysconf.cd-loc-base
                ub.shop.cd-parts-all = ub.sysconf.cd-parts-all
                ub.shop.cd-parts-not-blank = ub.sysconf.cd-parts-not-blank
                ub.shop.cd-parts-ser = ub.sysconf.cd-parts-ser
                ub.shop.cd-pb-alt = ub.sysconf.cd-pb-alt
                ub.shop.cd-pb-base = ub.sysconf.cd-pb-base
                ub.shop.cd-sc-base = ub.sysconf.cd-sc-base
                ub.shop.all-prt = ub.sysconf.all-prt.
     end.
end.
run waitfram-hide in this-procedure .
message "Заполнение полей таблицы МАГАЗИНЫ,"
                skip "ответственных за пересылку товаров на кассы,"
                skip "завершена!"
                skip "Обменяйтесь новостями с удаленными объектами!" view-as alert-box.
