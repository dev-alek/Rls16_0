block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pluhnalg.p $
$Archive: gbl/pluhnalg.p $

Процедура получения по номеру карты вида NNNNNNNNN? номера с рассчитанной КЦ NNNNNNNNNC по методу Luhna

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/12/05
Author: Bakhtadze Natalya
Creation date: 10/12/05

*/

define input parameter p-check-number as character no-undo .
define output parameter p-long-number  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pluhnalg.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/pluhnalg.p $":U .
define variable vss-description as character no-undo init "Процедура получения по номеру карты вида NNNNNNNNN? номера с рассчитанной КЦ NNNNNNNNNC по методу Luhna".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/luhn-alg.i }

define variable v-dopi as integer no-undo .
define variable v-pos as integer no-undo .
define variable v-check-number as character no-undo .

do
on error undo, return error
:

  if index(p-check-number , 'C') = 0 then do:
    undo, return error substitute("в номере карты &1 не определена позиция контрольной цифры"
                                   , p-check-number ).

  end.
  if num-entries(p-check-number, 'C') > 2 then do:
    undo, return error substitute("для карты &1 определено более 1 позиции контрольной цифры&2для алгоритма Luhna это невозможно"
                                   , p-check-number
                                   , {&new-line}
                                   ).
  end.

  assign
  v-pos  = index(p-check-number, 'C')
  v-check-number = p-check-number
  v-dopi = Luhn-algo(replace(p-check-number, 'C', '':U))
  no-error .
  if error-status:error then do:
    undo, return error substitute("ошибка при вычислении КЦ для карты &1:&2&3&2&4"
                                   , P-CHECK-NUMBER
                                   , {&new-line}
                                   , error-status:get-message(1)
                                   , return-value ).
  end.
  assign
  p-long-number = replace(v-check-number, 'C':U, string(v-dopi))
  .
end. /*doe*/
