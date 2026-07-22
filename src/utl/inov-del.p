block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inov-del.p $
$Archive: utl/inov-del.p $

Снятие отметки 'Требует переоценки' с удаленных товаров

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06

*/


define variable  vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable  vss-author      as character no-undo init "$Author: expertek $":U .
define variable  vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable  vss-workfile    as character no-undo init "$Workfile: inov-del.p $":U .
define variable  vss-archive     as character no-undo init "$Archive: utl/inov-del.p $":U .
define variable  vss-description as character no-undo init "Снятие отметки 'Требует переоценки' с удаленных товаров".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }

define variable  lok as logical no-undo .

assign
  lok = false
.
message
  "Снятие отметки 'Требует переоценки' с удаленных товаров. Продолжать ?"
  view-as alert-box question buttons OK-Cancel update lok .
if lok <> true then do:
  return . /* --->>>--- */
end.


run waitfram-show ("Обработка товаров. ЖДИТЕ...").
for each ub.goods no-lock
  where ub.goods.stts <> 0
:
  for each gds-obj
    where gds-obj.artic     = ub.goods.artic
      and gds-obj.prod-type = ub.goods.prod-type
      and gds-obj.prod-code = ub.goods.prod-code
  :
    if gds-obj.in-ov then do:
      accumulate gds-obj.artic (count).
      gds-obj.in-ov = no.
    end.
  end.
  accumulate ub.goods.artic (count).
  if ((accum count ub.goods.artic) modulo 10) = 0 then do:
    run waitfram-show in this-procedure  ("Удаленных товаров : " + string ((accum count ub.goods.artic)) +
                    "  Снято отметок : " + string ((accum count gds-obj.artic))).
  end.
end.
run waitfram-hide .

message
  "Всего обработано удаленных товаров:"
  (accum count ub.goods.artic) skip
  "Снято отметок:"
  (accum count gds-obj.artic)
  view-as alert-box.