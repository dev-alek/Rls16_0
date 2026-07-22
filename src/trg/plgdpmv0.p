block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Связывание складского места с товаром - не топливо

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/


DEFINE INPUT  PARAMETER pobj-type like ub.clients.obj-type     no-undo.
DEFINE INPUT  PARAMETER pobj-code like ub.clients.obj-code     no-undo.
DEFINE INPUT  PARAMETER ppl-code  like ub.place.pl-code        no-undo.
DEFINE INPUT  PARAMETER pgds-code like ub.goods.gds-code       no-undo.
DEFINE OUTPUT PARAMETER loc#log   as logical                   no-undo.

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Связывание складского места с товаром - не топливо" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }


define buffer bf_goods for ub.goods .
define buffer bf_units for ub.units .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

FIND FIRST ub.pl-gds No-LOCK WHERE
           ub.pl-gds.obj-type = pobj-type AND
           ub.pl-gds.obj-code = pobj-code AND
           ub.pl-gds.pl-code = ppl-code
           No-ERROR.
  IF AVAIL ub.pl-gds then do:
    find first bf_goods no-lock where
                bf_goods.gds-code = ub.pl-gds.gds-code.
    find first bf_units no-lock where
                bf_units.unit-name = bf_goods.unit-base .
    if lookup({&petrolium}, bf_units.type) > 0 AND
        lookup({&divisional}, bf_units.type) > 0 then do:
      assign
      loc#log = no.
      return
      ("объект " + pobj-type + string(pobj-code) + {&new-line} +
      "резервуар " + string(ppl-code) + " уже занят - товар " + string(ub.pl-gds.gds-code)) + {&space-char} + "(топливо)".
    end.
  END.
  create ub.pl-gds.
  assign
  ub.pl-gds.obj-type = pobj-type
  ub.pl-gds.obj-code = pobj-code
  ub.pl-gds.pl-code = ppl-code
  ub.pl-gds.gds-code = pgds-code
  ub.pl-gds.tolerance = 0
  ub.pl-gds.status_ = {&current-status}
  loc#log = yes
  .

end. /*doe*/
