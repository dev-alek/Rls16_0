block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getdbnum.p $
$Archive: gbl/getdbnum.p $

Получение  g#db-num окошке новостей - в момент когда ub подсоединена

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

define output parameter p-db-num as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getdbnum.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/getdbnum.p $":U .
define variable vss-description as character no-undo init "Получение  g#db-num окошке новостей - в момент когда ub подсоединена".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }


do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile ):


  define buffer bf_sys-ctrl for ub.sys-ctrl.
  find first bf_sys-ctrl no-lock.
  assign
    p-db-num = bf_sys-ctrl.db-num.


end. /*doe*/