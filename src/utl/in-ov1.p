block-level on error undo, throw.
/*

$Revision: bd053105d967, 188, rls $
$Author: SShalanin $
$Date: Thu Apr 23 14:36:18 2015 +0400 $
$Workfile: in-ov1.p $
$Archive: utl/in-ov1.p $

Снятие отметки 'Требует переоценки' с товаров

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06

*/


define variable  vss-revision    as character no-undo init "$Revision: bd053105d967, 188, rls $":U .
define variable  vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable  vss-date        as character no-undo init "$Date: Thu Apr 23 14:36:18 2015 +0400 $":U .
define variable  vss-workfile    as character no-undo init "$Workfile: in-ov1.p $":U .
define variable  vss-archive     as character no-undo init "$Archive: utl/in-ov1.p $":U .
define variable  vss-description as character no-undo init "Снятие отметки 'Требует переоценки' с удаленных товаров".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }

define variable  lok as logical no-undo .

assign
  lok = false
.
message
  "Снятие отметки 'Требует переоценки' с товаров. Продолжать ?"
  view-as alert-box question buttons OK-Cancel update lok .
if lok <> true then do:
  return . /* --->>>--- */
end.
define variable kk as integer   no-undo .
define variable k as integer   no-undo .


run waitfram-show ("Обработка товаров. ЖДИТЕ..."). 
k = 0 .
kk = 0 .
for each ub.goods no-lock
:
  for each ub.gds-obj
    where ub.gds-obj.artic     = ub.goods.artic
      and ub.gds-obj.prod-type = ub.goods.prod-type
      and ub.gds-obj.prod-code = ub.goods.prod-code
  :
    if ub.gds-obj.in-ov then do:
      k = k + 1.
      ub.gds-obj.in-ov = no.
    end.
  end.
  kk = kk + 1.
  if ( kk modulo 10) = 0 then do:
    run waitfram-show in this-procedure  ("Товаров : " + string (kk ) +
                    "  Снято отметок : " + string (k )).
  end.
end.
run waitfram-hide .

message
  "Всего обработано товаров:"
  kk skip
  "Снято отметок:"
  k
  view-as alert-box.