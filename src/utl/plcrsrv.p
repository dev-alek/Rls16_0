block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: plcrsrv.p $
$Archive: utl/plcrsrv.p $

Инициализация атрибута: резервирование товара по складским местам

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Перваков Михаил Сергеевич
Дата создания1: 04/11/06

*/

define input parameter p-install as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: plcrsrv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/plcrsrv.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }

define variable ind as integer no-undo .

if p-install = false then do:
  define variable lok as logical no-undo .

  assign
    lok = false
  .
  message
    "Инициализация атрибута товара:" skip
    "Резервирование товара по складским местам." skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update lok .
  if lok <> true then do:
    return . /* --->>>--- */
  end.
end.

define variable l-place-rsrv as logical no-undo .

run waitfram-show in this-procedure
  (input "Инициализация атрибута товара: Резервирование товара по складским местам."
  ).

for each ub.goods no-lock
:
  assign
    ind = ind + 1
  .
  if ind mod 10 = 0 then do:
    run waitfram-show in this-procedure
      (input "Инициализация атрибута товара. "
      + "Обработано " + string(ind) + ". "
      + "Артикул "
      + string(ub.goods.artic) + " "
      + string(ub.goods.prod-type) + " "
      + string(ub.goods.prod-code) + ". "
      ).

  end.

  find first ub.units no-lock
    where ub.units.unit-name = ub.goods.unit-base
    .
  if  lookup({&petrolium},  ub.units.type) > 0
  and lookup({&divisional}, ub.units.type) > 0 then do:
    assign
      l-place-rsrv = true
    .
  end.
  else do:
    assign
      l-place-rsrv = false
    .
  end.

  for each ub.gds-obj
    where ub.gds-obj.artic = ub.goods.artic
      and ub.gds-obj.prod-type = ub.goods.prod-type
      and ub.gds-obj.prod-code = ub.goods.prod-code
  :
    if ub.gds-obj.place-rsrv <> l-place-rsrv then do:
      assign
        ub.gds-obj.place-rsrv = l-place-rsrv
      .

      output to plcrsrv.txt append .
      export ub.gds-obj .
      output close .
    end.
  end.
end.

run waitfram-hide in this-procedure .

if p-install = false then do:
  message
    "Закончена инициализация атрибута товара" skip
    "Резервирование товара по складским местам" skip
    view-as alert-box information .
end.