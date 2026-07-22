block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление страны

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/04/05
Author: Bakhtadze Natalya
Creation date: 08/04/05

*/


TRIGGER PROCEDURE FOR DELETE OF ub.country.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление страны".
{ cmp/vssrevis.i "substitute('&1', ub.country.num-code) " }


main-block:
do
on error   undo main-block, return error return-value
on end-key undo main-block, return error return-value
:
  define buffer buf_country-attr for ub.country-attr.

/*  message                                                */
/*    vss-workfile vss-revision vss-description skip       */
/*    "Физическое удаление страны в системе запрещено" skip*/
/*    view-as alert-box error .                            */
/*  undo main-block, return error.                         */
  
  for each buf_country-attr where buf_country-attr.num-code = ub.country.num-code:
    delete buf_country-attr.
  end.

end.