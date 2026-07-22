block-level on error undo, throw.
/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Получение номера алгоритма для АНАЛИТИКИ!!!

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/15
Author: Dmitry Ukhanov
Creation date: 03/24/15

*/
define output parameter p-algo-num as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Получение номера алгоритма для АНАЛИТИКЕ!!!".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ rep/r-pychk0.i defalgo    }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  assign
    p-algo-num = {&current-algo-1}
  .
  return .

end.