block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getcurdt.p $
$Archive: gbl/getcurdt.p $

Возвращает текущую дату и время по текущему объекту

Автор: Перваков Михаил Сергеевич
Дата создания: 05/15/02
Author: Mikhail Pervakov
Creation date: 05/15/02

*/

define output parameter p-today as date      no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getcurdt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/getcurdt.p $":U .
define variable vss-description as character no-undo init "Возвращает текущую дату и время".
{ cmp/vssrevis.i }
{ gbl/cur-time.i }

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

do
on error undo, return error return-value
:
  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ).

  assign
    p-today = v-today
  .
end.

