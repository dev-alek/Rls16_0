block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-schfct.p $
$Archive: rep/g-schfct.p $

Журнал регистрации полученных счетов фактур

Автор: Комаров Иван Сергеевич
Дата создания: 12/23/09
Author: Ivan Komarov
Creation date: 12/23/09

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-schfct.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-schfct.p $":U .
define variable vss-description as character no-undo init "Журнал регистрации полученных счетов фактур".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/r-page1.i new }

do
on error undo, return error return-value
:

  run rep/d-report.w
    (input  parparentproc                                  /* parParentProc  */
    ,input  'rep/e-schfct.w'                               /* procname       */
    ,input  "ЖУРНАЛ РЕГИСТРАЦИИ ПОЛУЧЕННЫХ СЧЕТОВ-ФАКТУР"  /* namereport     */
    ,input  2                                              /* param-date     */
    ,input  ""                                             /* param-goods    */
    ,input  "{&o-firm},{&o-currency},{&o-choice},{&o-all}" /* param-obj      */
    ,input  ""                                             /* param-pay      */
    ,input  ""                                             /* param-pay-hide */
    ,input  "all,{&customer-yes}"                          /* param-universal*/
    ,input  false                                          /* param-alon     */
    ).
end.